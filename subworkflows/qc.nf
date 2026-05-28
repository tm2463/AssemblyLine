#!/usr/bin/env nextflow

include { QUAST 
          QUAST_SUMMARY } from '../modules/qc.nf'

workflow QC {

    take:
    assembly_ch

    main:
    assembly_ch
        .multiMap { ID, fastas ->
            fastas: fastas
        }
        .set { split_ch }
    
    QUAST(split_ch.fastas.collect())
    | QUAST_SUMMARY

    // emit:
    // qc_ch
}