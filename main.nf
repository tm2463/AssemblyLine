#!/usr/bin/env nextflow

def printHelp() {
    log.info """
Usage:
    nextflow run main.nf --input manifest.csv [options]

Required:
    --input                             Path to input manifest (columns: ID, R1, R2)

Optional:
    --help                              Show this help message

fastp:
    --min_depth                         Default: 30
    --lower_assembly_length             Default: 5500000

sylph:
    --sylph_db                          Path to sylph database (e.g. /path/to/.sylphdb)
    --sylph_taxonomy                    Sylph taxonomy label (default: gtdb_r232)
"""
}

include { FASTP 
          FILTER_FASTP 
          SYLPH_TAX_FILE
          SYLPH 
          SYLPH_TAX } from './modules/preprocessing.nf'

workflow {

    if (params.help) {
        printHelp()
        exit 0
    }

    if (!params.input) {
        log.error "No input provided. Use --input <path> or use --help for usage."
        exit 1
    }

    input_ch = Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row ->
            def ID = row.ID
            def R1 = file(row.R1, checkIfExists: true)
            def R2 = file(row.R2, checkIfExists: true)
            tuple(ID, R1, R2)
        }
    
    FASTP(input_ch)
    | FILTER_FASTP
    | filter { ID, R1, R2, fastp_out -> fastp_out.trim() == 'PASS' }
    | map { ID, R1, R2, fastp_out -> tuple(ID, R1, R2) }
    | SYLPH
    
    SYLPH_TAX_FILE()

    SYLPH.out.sylph_out
        .map { ID, R1, R2, sylph_profile -> tuple(ID, R1, R2, sylph_profile) }
        .combine(SYLPH_TAX_FILE.out.tax)
        .map { ID, R1, R2, sylph_profile, tax_file -> tuple(ID, R1, R2, sylph_profile, tax_file) }
        | SYLPH_TAX
        | filter { ID, R1, R2, sylph_out -> sylph_out.trim() == 'PASS' }
        


    // | BWA   


    

    // profile samples with sylph
    // map to reference with bwa
}
