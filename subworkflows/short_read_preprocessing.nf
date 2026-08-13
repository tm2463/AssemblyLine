#!/usr/bin/env nextflow

include { FASTQC } from '../modules/fastqc.nf'
include { FASTP 
          FILTER_FASTP } from '../modules/fastp.nf'

workflow SHORT_READ_PREPROCESSING {

    take:
    input_ch

    main:
    FASTQC(input_ch)
    
    FASTP(input_ch)
        | FILTER_FASTP
        | filter { it -> it[3].trim() == 'PASS' }
        | map { it -> it[0..2] }
        | set { fastp_out_ch }

    emit:
    fastp_out_ch
}