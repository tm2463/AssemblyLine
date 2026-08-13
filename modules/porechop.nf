process PORECHOP {
    tag "${ID}"
    label "small"

    container "quay.io/biocontainers/porechop:0.2.4--py311he264feb_9"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("*_trimmed.fastq.gz"), val(size), emit: fastq
    
    script:
    def long_fastq="${reads[0]}"
    """
    porechop -i ${long_fastq} -o ${ID}_trimmed.fastq.gz --threads ${task.cpus}
    """
}