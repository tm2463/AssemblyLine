#!/usr/bin/env nextflow

include { BAKTA 
          ABRICATE } from '../modules/annotation.nf'

workflow ANNOTATION {

    take:
    assembly_ch

    main:
    BAKTA(assembly_ch)

    // emit:
    // ANNOTATION.out.annotation_ch
}