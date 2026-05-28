process QUAST {
    // https://github.com/ablab/quast
    label 'small'

    container "quay.io/biocontainers/quast:5.3.0--py313pl5321h5ca1c30_2"

    input:
    path fastas, stageAs: 'fastas/*'

    output:
    path "quast/transposed_report.tsv"

    script:
    """
    quast.py fastas/* -o quast --no-plot --no-html --threads ${task.cpus}
    """
}

process QUAST_SUMMARY {
    label 'small'

    container "quay.io/biocontainers/pandas:2.2.1"

    publishDir mode: 'copy', path: "${params.outdir}/quast_summary/"

    input:
    path quast_report

    output:
    path "quast_summary.tsv"

    script:
    def command = "${projectDir}/bin/quast_summary.py"
    """
    ${command} --input ${quast_report} --output quast_summary.tsv
    """
}