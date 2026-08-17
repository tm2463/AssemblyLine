#!/usr/bin/env nextflow

include { SHORT_READ_PREPROCESSING } from '../subworkflows/short_read_preprocessing.nf'
include { LONG_READ_PREPROCESSING } from '../subworkflows/long_read_preprocessing.nf'

workflow PREPROCESSING {

    take:
    input_ch

    main:
    if (params.mode == 'short') {
        SHORT_READ_PREPROCESSING(input_ch)
            .set { preprocessed_ch }

    } else if (params.mode == 'long') {
        LONG_READ_PREPROCESSING(input_ch)
            .set { preprocessed_ch }

    } else if (params.mode == 'hybrid') {
        short_reads_ch = input_ch.map { ID, reads, size -> tuple(ID, [reads[0], reads[1]], size) }
        long_reads_ch = input_ch.map { ID, reads, size -> tuple(ID, [reads[2]], size) }

        SHORT_READ_PREPROCESSING(short_reads_ch)
        LONG_READ_PREPROCESSING(long_reads_ch)

        SHORT_READ_PREPROCESSING.out
            .join(LONG_READ_PREPROCESSING.out)
            .map { ID, short_reads, size, long_reads, size2 ->
                tuple(ID, short_reads + long_reads, size)
            }
            .set { preprocessed_ch }
    
    } else {
        error "Unknown params.mode: '${params.mode}'. Expected 'short', 'long', or 'hybrid'."
    }

    emit:
    preprocessed_ch

}