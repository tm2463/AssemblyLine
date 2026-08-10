#!/usr/bin/env nextflow

include { SHOVILL } from '../modules/shovill.nf'
include { DRAGONFLYE 
          MAKE_UNIQUE_READ_IDS } from '../modules/dragonflye.nf'
include { UNICYCLER } from '../modules/unicycler.nf'
include { QUAST } from '../modules/quast.nf'
include { CHECKM2 } from '../modules/checkm2.nf'
include { FASTANI } from '../modules/fastani.nf'
include { MLST } from '../modules/mlst.nf'
include { COLLECT_REPORTS 
          MERGE_REPORTS } from '../modules/reporting.nf'

workflow ASSEMBLY {

    take:
    assembly_ch

    main:
    def qc_ch
    if (params.mode == "short") {
        SHOVILL(assembly_ch)
        qc_ch = SHOVILL.out
    } else if (params.mode == "long") {
        MAKE_UNIQUE_READ_IDS(assembly_ch)
        | DRAGONFLYE
        qc_ch = DRAGONFLYE.out
    } else if (params.mode == "hybrid") {
        UNICYCLER(assembly_ch)
        qc_ch = UNICYCLER.out
    }
    
    qc_ch
        .multiMap { it ->
            quast: it
            checkm2: it
            fastani: it
            mlst: it
        }
        .set { split_ch }

    QUAST(split_ch.quast)

    ref_ch = Channel.value(file(params.reference, checkIfExists: true))
    FASTANI(split_ch.fastani, ref_ch)

    checkm2_db = Channel.value(file(params.checkm2_db, checkIfExists: true))
    CHECKM2(split_ch.checkm2, checkm2_db)

    MLST(split_ch.mlst)

    report_ch = qc_ch
        .join(QUAST.out.quast_out)
        .join(FASTANI.out.fastani_out)
        .join(CHECKM2.out.checkm2_out)
        .join(MLST.out.mlst_out)

    COLLECT_REPORTS(report_ch)

    merge_ch = COLLECT_REPORTS.out.report.collect()
    MERGE_REPORTS(merge_ch)

    COLLECT_REPORTS.out.contigs
        | filter { it -> it[2].trim() == 'PASS' }
        | map { it -> it[0..1] }
        | set { contigs_ch }

    emit:
    contigs_ch

}