#!/usr/bin/env nextflow

include { BAKTA 
          ABRICATE } from '../modules/annotation.nf'

workflow ANNOTATION {

    take:
    assembly_ch

    main:
    bakta_db_ch = Channel.value(file(params.bakta_db, checkIfExists: true))
    BAKTA(assembly_ch, bakta_db_ch)
    ABRICATE(assembly_ch)

    // emit:
    // ANNOTATION.out.annotation_ch
}