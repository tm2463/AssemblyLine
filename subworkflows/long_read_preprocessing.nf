#!/usr/bin/env nextflow

include { NANOPLOT } from '../modules/nanoplot.nf'
include { PORECHOP } from '../modules/porechop.nf'
include { FILTLONG } from '../modules/filtlong.nf'
include { RASUSA } from '../modules/rasusa.nf'

include { DECONTAMINATION } from '../subworkflows/decontamination.nf'

workflow LONG_READ_PREPROCESSING {

    take:
    input_ch

    main:
    NANOPLOT(input_ch)

    PORECHOP(input_ch)
    | FILTLONG
    | DECONTAMINATION

    if (params.downsample_reads) {
        RASUSA(DECONTAMINATION.out)
        long_out_ch = RASUSA.out.downsampled_reads
    } else {
        long_out_ch = DECONTAMINATION.out
    }

    emit:
    long_out_ch

}
