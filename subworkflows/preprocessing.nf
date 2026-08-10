#!/usr/bin/env nextflow

include { FASTP 
          FASTPLONG } from '../modules/fastp.nf'
include { SYLPH 
          SYLPH_TAX } from '../modules/sylph.nf'
include { BWA
          SAMTOOLS 
          FILTER_SAMTOOLS } from '../modules/mapping.nf'

workflow PREPROCESSING {

    take:
    input_ch

    main:
    def sylph_ch

    if (params.mode == 'short') {
        FASTP(input_ch)
        sylph_ch = FASTP.out.fastp

    } else if (params.mode == 'long') {
        FASTPLONG(input_ch)
        sylph_ch = FASTPLONG.out.fastplong

    } else if (params.mode == 'hybrid') {
        FASTP(input_ch.map { ID, reads, size -> tuple(ID, [reads[0], reads[1]], size) })
        FASTPLONG(input_ch.map { ID, reads, size -> tuple(ID, [reads[2]], size) })

        sylph_ch = FASTP.out.fastp
            | join(FASTPLONG.out.fastplong, by: 0)
            | map { ID, short_reads, size, long_reads, size2 ->
                tuple(ID, short_reads + long_reads, size)
            }
    }

    // FILTER_FASTP(sylph_ch)
    // | filter { it -> it[3].trim() == 'PASS' }
    // | map { it -> it[0..2] }
    // | set { fastp_out_ch }

    sylph_db_ch = Channel.value(file(params.sylph_db, checkIfExists: true))
    
    SYLPH(sylph_ch, sylph_db_ch)
    | SYLPH_TAX

    SYLPH_TAX.out.sylph_tax
        | filter { it -> it[4].trim() == 'PASS' }
        | map { it -> it[0..2] }
        | set { mapping_ch }

    if (params.mode == 'short') {
        ref_ch = Channel.value(file(params.reference, checkIfExists: true))
        BWA(mapping_ch, ref_ch) 
        | SAMTOOLS
        | FILTER_SAMTOOLS

        FILTER_SAMTOOLS.out.samtools_out
        | filter { it -> it[3].trim() == 'PASS' }
        | map { it -> it[0..2] }
        | set { preprocessed_ch }
    } else {
        preprocessed_ch = mapping_ch
    }

    emit:
    preprocessed_ch

}