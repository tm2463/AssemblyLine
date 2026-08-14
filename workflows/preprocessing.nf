#!/usr/bin/env nextflow

include { BWA
          SAMTOOLS 
          FILTER_SAMTOOLS } from '../modules/mapping.nf'

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

        short_reads_out = SHORT_READ_PREPROCESSING.out.map { ID, reads, size -> tuple(ID, [reads[0], reads[1]], size) }
        long_reads_out = LONG_READ_PREPROCESSING.out.map { ID, reads, size -> tuple(ID, [reads[2]], size) }
        
        short_reads_out
            .join(long_reads_out)
            .map { ID, short_reads, size, long_reads, size2 ->
                tuple(ID, short_reads + long_reads, size)
            }
            .set { preprocessed_ch }
    
    } else {
        error "Unknown params.mode: '${params.mode}'. Expected 'short', 'long', or 'hybrid'."
    }


    // if (params.mode == 'short') {
    //     ref_ch = Channel.value(file(params.reference, checkIfExists: true))
    //     BWA(mapping_ch, ref_ch) 
    //     | SAMTOOLS
    //     | FILTER_SAMTOOLS

    //     FILTER_SAMTOOLS.out.samtools_out
    //     | filter { it -> it[3].trim() == 'PASS' }
    //     | map { it -> it[0..2] }
    //     | set { preprocessed_ch }
    // } else {
    //     preprocessed_ch = mapping_ch
    // }

    emit:
    preprocessed_ch

}