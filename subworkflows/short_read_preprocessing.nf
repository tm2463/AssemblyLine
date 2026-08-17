#!/usr/bin/env nextflow

include { FASTQC } from '../modules/fastqc.nf'
include { FASTP 
          FILTER_FASTP } from '../modules/fastp.nf'
include { BWA
          SAMTOOLS
          FILTER_SAMTOOLS } from '../modules/mapping.nf'

include { DECONTAMINATION } from '../subworkflows/decontamination.nf'

workflow SHORT_READ_PREPROCESSING {

    take:
    input_ch

    main:
    FASTQC(input_ch)
    
    FASTP(input_ch)
    | FILTER_FASTP
    | filter { it -> it[3].trim() == 'PASS' }
    | map { it -> it[0..2] }
    | DECONTAMINATION
    
    if (params.reference) {
        ref_ch = Channel.value(file(params.reference, checkIfExists: true))
        mapping_ch = DECONTAMINATION.out
        BWA(mapping_ch, ref_ch) 
        | SAMTOOLS
        | FILTER_SAMTOOLS

        FILTER_SAMTOOLS.out.samtools_out
        | filter { it -> it[3].trim() == 'PASS' }
        | map { it -> it[0..2] }
        | set { short_out_ch }
    } else {
        short_out_ch = DECONTAMINATION.out
    }

    emit:
    short_out_ch

}