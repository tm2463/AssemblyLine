#!/usr/bin/env nextflow

include { SHOVILL 
          DRAGONFLYE 
          MAKE_UNIQUE_READ_IDS } from '../modules/assembly.nf'
include { QUAST 
          QUAST_SUMMARY } from '../modules/quast.nf'
include { CHECKM2 } from '../modules/checkm2.nf'
include { FASTANI } from '../modules/fastani.nf'
include { REPORT } from '../modules/report.nf'

workflow ASSEMBLY {

    take:
    assembly_ch

    main:
    def qc_ch
    if (params.mode == "short") {
        SHOVILL(assembly_ch)
        qc_ch = SHOVILL.out
    } else {
        MAKE_UNIQUE_READ_IDS(assembly_ch)
        | DRAGONFLYE
        qc_ch = DRAGONFLYE.out
    }
    
    qc_ch
        .multiMap { it ->
            quast: it
            checkm2: it
            fastani: it
        }
        .set { split_ch }

    QUAST(split_ch.quast)
    | QUAST_SUMMARY

    ref_ch = Channel.value(file(params.reference, checkIfExists: true))
    FASTANI(split_ch.fastani, ref_ch)

    checkm2_db = Channel.value(file(params.checkm2_db, checkIfExists: true))
    CHECKM2(split_ch.checkm2, checkm2_db)

    report_ch = qc_ch
        .join(QUAST_SUMMARY.out.quast_out)
        .join(FASTANI.out.fastani_out)
        .join(CHECKM2.out.checkm2_out)

    REPORT(report_ch)

    // TODO: add pass_fail to reporting script, and merge report to publish
    // Also need to add reporting to preprocessing, pass/fail already handled, just need to collect reports

    emit:
    report_ch

}