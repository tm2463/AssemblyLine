process QUAST {
    // https://github.com/ablab/quast
    tag "${ID}"
    label 'small'

    container 'quay.io/biocontainers/quast:5.3.0--py39pl5321heaaa4ec_0'

    input:
    tuple val(ID), path(fasta)

    output:
    tuple val(ID), path(fasta), path("${ID}_quast_report.tsv")

    script:
    quast_report = "${ID}_quast_report.tsv"
    """
    quast.py ${fasta} -o quast --no-html --no-plots
    mv quast/transposed_report.tsv ${quast_report}
    """
}

process QUAST_SUMMARY {
    tag "${ID}"
    label 'small'

    container 'quay.io/biocontainers/pandas:2.2.1'

    input:
    tuple val(ID), path(fasta), path(quast_report)

    output:
    tuple val(ID), path(fasta), path("${meta.ID}_quast_summary.tsv"), emit: quast_summary

    script:
    def command="${projectDir}/bin/quast_summary.py"
    def report_tsv="${meta.ID}_quast_summary.tsv"
    """
    ${command} \\
        --input ${quast_report} \\
        --output ${report_tsv}
    """
}