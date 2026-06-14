#!/usr/bin/env nextflow

include { SHOVILL 
          DRAGONFLYE } from '../modules/assembly.nf'

workflow ASSEMBLY {

    take:
    assembly_ch

    main:
    if (params.mode == "short") {
        SHOVILL(assembly_ch)
        contigs = SHOVILL.out
    } else {
        DRAGONFLYE(assembly_ch)
        contigs = DRAGONFLYE.out
    }

    contigs_ch = contigs

    emit:
    contigs_ch
}