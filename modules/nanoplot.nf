process NANOPLOT {
    tag "${ID}"
    label 'small'

    container "quay.io/biocontainers/nanoplot:1.47.1--pyhdfd78af_0"

    publishDir "${params.outdir}/nanoplot"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("*.html"), emit: html
    tuple val(ID), path("*.txt"), emit: txt

    script:
    def long_fastq="${reads[0]}"
    """
    NanoPlot --fastq ${long_fastq} -p ${ID}
    """
}