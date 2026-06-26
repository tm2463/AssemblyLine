#!/usr/bin/env nextflow

include { FASTP 
          FASTPLONG 
          FILTER_FASTP } from '../modules/fastp.nf'
include { SYLPH_TAX_FILE
          SYLPH 
          SYLPH_TAX } from '../modules/sylph.nf'
include { BWA
          SAMTOOLS 
          FILTER_SAMTOOLS } from '../modules/mapping.nf'

workflow PREPROCESSING {

    take:
    input_ch

    main:
    def filter_ch
    if (params.mode == 'short') {
        FASTP(input_ch)
        filter_ch = FASTP.out.fastp
            | map { ID, R1, R2, size, json -> tuple(ID, [R1, R2], size, json) }
    } else if (params.mode == 'long') {
        FASTPLONG(input_ch)
        filter_ch = FASTPLONG.out.fastplong
            | map { ID, fastq, size, json -> tuple(ID, [fastq], size, json) }
    }

    FILTER_FASTP(filter_ch)
    | filter { it -> it[3].trim() == 'PASS' }
    | map { it -> it[0..2] }
    | set { fastp_out_ch }

    sylph_db_ch = Channel.value(file(params.sylph_db, checkIfExists: true))
    
    SYLPH(fastp_out_ch, sylph_db_ch)
    
    SYLPH_TAX_FILE()

    SYLPH.out.sylph_out
        .combine(SYLPH_TAX_FILE.out.tax)
        | SYLPH_TAX
        | filter { it -> it[4].trim() == 'PASS' }
        | map { it -> it[0..2] }
        | set { sylph_tax_ch }

    sylph_tax_ch.set { preprocessed_ch }

    if (params.mode == 'short') {
        ref_ch = Channel.value(file(params.reference, checkIfExists: true))
        BWA(sylph_tax_ch, ref_ch) 
        | SAMTOOLS
        | FILTER_SAMTOOLS
        | filter { it -> it[3].trim() == 'PASS' }
        | map { it -> it[0..2] }
        | set { preprocessed_ch }
    }

    emit:
    preprocessed_ch

}
