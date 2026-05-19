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
          SYLPH_TAX 
          BWA 
          SAMTOOLS } from './modules/preprocessing.nf'

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
    | filter { it -> it[3].trim() == 'PASS' }
    | map { ID, R1, R2, fastp_out -> tuple(ID, R1, R2) }
    | set { fastp_out_ch }

    sylph_db_ch = Channel.value(file(params.sylph_db, checkIfExists: true))
    
    SYLPH(fastp_out_ch, sylph_db_ch)
    
    SYLPH_TAX_FILE()

    SYLPH.out.sylph_out
        .combine(SYLPH_TAX_FILE.out.tax)
        | SYLPH_TAX
        | filter { it -> it[3].trim() == 'PASS' }
        | map { ID, R1, R2, fastp_out -> tuple(ID, R1, R2) }
        | BWA
        | SAMTOOLS

}
