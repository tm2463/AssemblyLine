#!/usr/bin/env nextflow

include { SHOVILL 
          DRAGONFLYE 
          MAKE_UNIQUE_READ_IDS } from '../modules/assembly.nf'
include { QUAST } from '../modules/quast.nf'

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

    QUAST(contigs)
    contigs_ch = QUAST.out.results

    emit:
    contigs_ch
}