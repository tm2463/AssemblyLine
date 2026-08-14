process FILTLONG {
    tag "${ID}"
    label 'small'

    container "quay.io/biocontainers/filtlong:0.3.1--h077b44d_0"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("${ID}_filtlong.fastq.gz"), val(size), emit: filtlong

    script:
    def long_fastq="${reads[0]}"
    def out_fastq="${ID}_filtlong.fastq.gz"
    """
    filtlong \
        --min_length 1000 \
        --keep_percent 90 \
        --target_bases 500000000 \
        ${long_fastq} \
    | gzip > ${out_fastq}
    """
}