#!/usr/bin/env nextflow

include { CHECKM2 
          GUNC } from '../modules/qc.nf'

workflow QC {

    take:
    assembly_ch

    main:
    checkm2_db_ch = Channel.value(file(params.checkm2_db, checkIfExists: true))
    gunc_db_ch = Channel.value(file(params.gunc_db, checkIfExists: true))
    
    CHECKM2(assembly_ch, checkm2_db_ch)
    GUNC(assembly_ch, gunc_db_ch)
    

    // emit:
    // qc_ch
}