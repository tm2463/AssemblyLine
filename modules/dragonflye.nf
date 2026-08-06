process DRAGONFLYE {
    // https://github.com/rpetit3/dragonflye
    tag "${ID}"
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
    dragonflye --outdir results --reads ${fastq} ${genome_size} --ram ${memory} --assembler ${params.long_assembler} --cpus ${task.cpus}
    mv results/contigs.fa "${prefix}"
    """
}

process MAKE_UNIQUE_READ_IDS {
    tag "${ID}"
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