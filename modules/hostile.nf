process HOSTILE {
    tag "${ID}"
    label "medium"

    container "quay.io/biocontainers/hostile:2.0.2--pyhdfd78af_0"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("${ID}*.clean*"), val(size), emit: cleaned_reads

    script:
    def n = reads.size()
    if (n == 1) {
        // long reads only
        """
        hostile clean \\
            --fastq1 ${reads[0]} \\
            --aligner minimap2 \\
            --threads ${task.cpus} \\
            --out-dir . \\
        """
    } else if (n == 2) {
        // short paired-end only
        """
        hostile clean \\
            --fastq1 ${reads[0]} \\
            --fastq2 ${reads[1]} \\
            --aligner bowtie2 \\
            --threads ${task.cpus} \\
            --out-dir . \\
        """
    }
}