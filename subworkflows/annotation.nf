#!/usr/bin/env nextflow

include { BAKTA 
          ABRICATE } from '../modules/annotation.nf'
include { MLST } from '../modules/mlst.nf'

workflow ANNOTATION {

    take:
    assembly_ch

    main:
    bakta_db_ch = Channel.value(file(params.bakta_db, checkIfExists: true))

    assembly_ch
        .multiMap { it ->
            bakta: it
            abricate: it
            mlst: it
            // DefenceFinder (https://github.com/mdmparis/defense-finder) -> CRISPRCasFinder
            // GECCO / antiSMASH -> biosynthetic gene clusters (https://zellerlab.github.io/tools/gecco)
            // Mobile Genetic Elements (sequence indexes?)
        }
        .set { split_ch }

    BAKTA(split_ch.bakta, bakta_db_ch)
    ABRICATE(split_ch.abricate)
    MLST(split_ch.mlst)

}