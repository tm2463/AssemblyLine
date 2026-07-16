process REPORT {
    tag "${ID}"
    label 'small'

    container 'quay.io/biocontainers/pandas:2.2.1'

    input:
    tuple val(ID), path(fasta), path(quast), path(fastani), path(checkm2)

    output:
    tuple val(ID), path(fasta), stdout, emit: contigs
    tuple val(ID), path("${ID}_report.tsv"), emit: report

    script:
    def command="${projectDir}/bin/collect_report.py"
    """
    ${command} \\
        --id ${ID} \\
        --quast ${quast} \\
        --fastani ${fastani} \\
        --checkm2 ${checkm2}
    """
}