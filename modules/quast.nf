process QUAST {
    // https://github.com/ablab/quast
    tag "${ID}"
    label 'small'

    container 'quay.io/biocontainers/quast:5.3.0--py39pl5321heaaa4ec_0'

    input:
    tuple val(ID), path(fasta)

    output:
    tuple val(ID), path("${ID}_quast_report.tsv"), emit: quast_out

    script:
    quast_report = "${ID}_quast_report.tsv"
    """
    quast.py ${fasta} -o quast --no-html --no-plots
    mv quast/transposed_report.tsv ${quast_report}
    """
}
