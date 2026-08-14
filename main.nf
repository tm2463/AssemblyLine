#!/usr/bin/env nextflow

include { printHelp 
          validateParams 
          setInputChannel 
          validateManifest } from './modules/helper_functions.nf'

include { PREPROCESSING } from './workflows/preprocessing.nf'
include { ASSEMBLY } from './workflows/assembly.nf'
include { ANNOTATION } from './workflows/annotation.nf'

workflow {

    if (params.help) {
        printHelp()
        exit 0
    }

    validateParams()
    validateManifest()

    input_ch = setInputChannel()

    def assembly_ch
    if (!params.skip_preprocessing) {
        PREPROCESSING(input_ch)
        assembly_ch = PREPROCESSING.out.preprocessed_ch
    } else {
        assembly_ch = input_ch
    }

    ASSEMBLY(assembly_ch)
    | ANNOTATION

}
