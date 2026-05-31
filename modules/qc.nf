process CHECKM2 {
    // https://github.com/chklovski/CheckM2
    label 'medium'

    publishDir "${params.outdir}/qc"

    container "quay.io/biocontainers/checkm2:1.1.0--pyh7e72e81_1"

    input:
    path fastas, stageAs: 'fastas/*'
    path checkm2_db

    output:
    path "checkm2_report.tsv"

    script:
    """
    checkm2 predict --input fastas --output-directory checkm2 --threads ${task.cpus} -x .fa --database_path ${checkm2_db}
    mv checkm2/quality_report.tsv checkm2_report.tsv
    """
}
