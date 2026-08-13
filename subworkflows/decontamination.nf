#!/usr/bin/env nextflow

include { HOSTILE } from '../modules/hostile.nf'

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

    emit:


}