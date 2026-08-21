process RASUSA {
    // https://github.com/mbhall88/rasusa
    tag "${ID}"
    label "small"

    container "quay.io/biocontainers/rasusa:5.1.0--hfa8f182_0"

    input:
    tuple val(ID), path(reads), val(genome_size)

    output:
    tuple val(ID), path("${ID}_rasusa.fastq.gz"), val(genome_size), emit: downsampled_reads

    script:
    def size = params.target_genome_size ?: genome_size
    def long_fastq = reads[0]
    """
    rasusa \
        reads \
        --coverage ${params.target_coverage} \
        --genome-size ${size} \
        ${long_fastq} \
    > ${ID}_rasusa.fastq

    gzip ${ID}_rasusa.fastq
    """
}