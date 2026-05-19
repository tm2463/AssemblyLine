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

include { PREPROCESSING } from './subworkflows/preprocessing.nf'

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

    def assembly_ch

    // samtools output needs filtering -> currently just emits mapping stats
    // need filter script to print PASS/FAIL to stdout
    if (!params.skip_preprocessing) {
        assembly_ch = PREPROCESSING(input_ch)
    } else {
        assembly_ch = input_ch
    }

}
