#!/usr/bin/env nextflow

include { HOSTILE } from '../modules/hostile.nf'
include { SYLPH 
          SYLPH_TAX } from '../modules/sylph.nf'

workflow DECONTAMINATION {

    take:
    preprocessed_ch

    main:
    def cleaned_ch

    if (params.remove_host_reads) {
        HOSTILE(preprocessed_ch)
        cleaned_ch = HOSTILE.out
    } else {
        cleaned_ch = preprocessed_ch
    }

    sylph_db_ch = Channel.value(file(params.sylph_db, checkIfExists: true))

    SYLPH(cleaned_ch, sylph_db_ch)
    | SYLPH_TAX

    SYLPH_TAX.out.sylph_tax
        | filter { it -> it[4].trim() == 'PASS' }
        | map { it -> it[0..2] }
        | set { mapping_ch }

    emit:
    mapping_ch

}