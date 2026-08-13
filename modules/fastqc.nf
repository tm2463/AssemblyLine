process FASTQC {
    tag "${ID}"
    label 'small'

    container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"

    publishDir "${params.outdir}/fastqc"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("*.zip"), emit: zip
    tuple val(ID), path("*.html"), emit: html

    script:
    def R1="${reads[0]}"
    def R2="${reads[1]}"
    """
    fastqc ${R1} ${R2}
    """
}