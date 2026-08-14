#!/usr/bin/env nextflow

include { NANOPLOT } from '../modules/nanoplot.nf'
include { PORECHOP } from '../modules/porechop.nf'
include { FILTLONG } from '../modules/filtlong.nf'

include { DECONTAMINATION } from '../subworkflows/decontamination.nf'

workflow LONG_READ_PREPROCESSING {

    take:
    input_ch

    main:
    NANOPLOT(input_ch)

    PORECHOP(input_ch)
    | FILTLONG
    | DECONTAMINATION

    emit:
    DECONTAMINATION.out

}
