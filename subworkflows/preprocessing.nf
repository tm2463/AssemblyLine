#!/usr/bin/env nextflow

include { FASTP 
          FILTER_FASTP 
          SYLPH_TAX_FILE
          SYLPH 
          SYLPH_TAX 
          BWA } from '../modules/preprocessing.nf'

workflow PREPROCESSING {

    take:
    input_ch

    main:
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
        | set { preprocessed_ch }

    emit:
    preprocessed_ch
}
