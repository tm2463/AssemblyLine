process SHOVILL {
    // https://github.com/tseemann/shovill
    label 'large'

    container "quay.io/biocontainers/shovill:1.4.2--hdfd78af_0"

    publishDir "${params.outdir}/${ID}"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("${ID}_contigs.fa")

    script:
    def R1="${reads[0]}"
    def R2="${reads[1]}"
    """
    shovill --outdir results --R1 ${R1} --R2 ${R2} --cpus ${task.cpus} --minlen ${params.min_contig_length}
    mv results/contigs.fa "${ID}_contigs.fa"
    """
}

process DRAGONFLYE {
    // https://github.com/rpetit3/dragonflye
    label 'large'

    container "quay.io/biocontainers/dragonflye:1.2.1--hdfd78af_0"

    publishDir "${params.outdir}/${ID}"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("${ID}_contigs.fa")

    script:
    def fastq="${reads[0]}"
    def genome_size = size != null ? "--gsize ${size}" : ""
    def prefix = "${ID}_contigs.fa"
    def memory = task.memory.toGiga() - 2
    """
    dragonflye --outdir results --reads ${fastq} ${genome_size} --ram ${memory}
    mv results/contigs.fa "${prefix}"
    """
}

process MAKE_UNIQUE_READ_IDS {
    label 'small'

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("${ID}.unique.fq.gz"), val(size)

    script:
    """
    zcat ${reads} \
    | awk '
        NR%4==1 {
            sub(/^@/, "", \$0)
            print "@" \$0 "_" ++i
            next
        }
        {print}
    ' \
    | gzip > ${ID}.unique.fq.gz
    """
}