#!/usr/bin/env nextflow

include { SHOVILL 
          DRAGONFLYE 
          MAKE_UNIQUE_READ_IDS } from '../modules/assembly.nf'

workflow ASSEMBLY {

    take:
    assembly_ch

    main:
    if (params.mode == "short") {
        SHOVILL(assembly_ch)
        contigs = SHOVILL.out
    } else {
        MAKE_UNIQUE_READ_IDS(assembly_ch)
        | DRAGONFLYE
        contigs = DRAGONFLYE.out
    }

    contigs_ch = contigs

    emit:
    contigs_ch
}