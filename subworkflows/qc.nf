#!/usr/bin/env nextflow

include { QUAST } from '../modules/qc.nf'

workflow QC {

    take:
    assembly_ch

    main:
    assembly_ch
        .multiMap { ID, fastas ->
            ids: ID
            fastas: fastas
        }
        .set { split_ch }
    
    QUAST(
        split_ch.ids.collect(),
        split_ch.fastas.collect()
    )

    emit:
    qc_ch
}