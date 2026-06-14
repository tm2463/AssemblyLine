#!/usr/bin/env nextflow

include { printHelp 
          validateParams 
          setInputChannel 
          validateManifest } from './modules/helper_functions.nf'

include { PREPROCESSING } from './subworkflows/preprocessing.nf'
include { SHOVILL } from './modules/assembly.nf'
include { QC } from './subworkflows/qc.nf'
include { ANNOTATION } from './subworkflows/annotation.nf'

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
        assembly_ch = PREPROCESSING(input_ch)
    } else {
        assembly_ch = input_ch
    }

    SHOVILL(assembly_ch)
    | ( QC & ANNOTATION )

}
