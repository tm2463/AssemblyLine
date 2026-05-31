#!/usr/bin/env nextflow

include { printHelp } from './modules/helper_functions.nf'

include { PREPROCESSING } from './subworkflows/preprocessing.nf'
include { SHOVILL } from './modules/assembly.nf'
include { QC } from './subworkflows/qc.nf'

workflow {

    if (params.help) {
        printHelp()
        exit 0
    }

    input_ch = Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row ->
            def ID = row.ID
            def R1 = file(row.R1, checkIfExists: true)
            def R2 = file(row.R2, checkIfExists: true)
            tuple(ID, R1, R2)
        }

    def assembly_ch
    if (!params.skip_preprocessing) {
        assembly_ch = PREPROCESSING(input_ch)
    } else {
        assembly_ch = input_ch
    }

    SHOVILL(assembly_ch)
    | QC

}
