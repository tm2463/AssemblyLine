#!/usr/bin/env nextflow

include { HOSTILE } from '../modules/hostile.nf'
include { SYLPH_SKETCH 
          SYLPH_PROFILE } from '../modules/sylph.nf'

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

    SYLPH_SKETCH(cleaned_ch)

    sylph_db_ch = Channel.value(file(params.sylph_db, checkIfExists: true))
    
    SYLPH_PROFILE(SYLPH_SKETCH.out.sylph_profile, sylph_db_ch)
        | filter { it -> it[3].trim() == 'PASS' }
        | map { it -> it[0..2] }
        | set { mapping_ch }

    emit:
    mapping_ch

}