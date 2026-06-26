#!/usr/bin/env nextflow

include { CHECKM2 
          FASTANI } from '../modules/qc.nf'

workflow QC {

    take:
    assembly_ch

    main:
    ref_ch = Channel.value(file(params.reference, checkIfExists: true))
    
    FASTANI(assembly_ch, ref_ch)

    checkm2_db = Channel.value(file(params.checkm2_db, checkIfExists: true))

    checkm2_ch = assembly_ch
        .map { ID, fastas -> fastas}
        .collect()

    CHECKM2(checkm2_ch, checkm2_db)

}