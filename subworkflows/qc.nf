#!/usr/bin/env nextflow



workflow QC {

    take:
    assembly_ch

    main:
    assembly_ch
    | QUAST

    emit:
    qc_ch
}