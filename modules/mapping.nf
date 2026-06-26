// potential update to minibwa (https://github.com/lh3/minibwa) if proven useful
process BWA {
    // https://github.com/bwa-mem2/bwa-mem2
    tag "${ID}"
    label 'medium'

    container "quay.io/biocontainers/bwa-mem2:2.3--he70b90d_0"

    input:
    tuple val(ID), path(reads), val(size)
    path(ref)

    output:
    tuple val(ID), path(reads), val(size), path("${ID}.sam")

    script:
    def R1="${reads[0]}"
    def R2="${reads[1]}"
    """
    bwa-mem2 index -p ${ID} ${ref}
    bwa-mem2 mem -t ${task.cpus} ${ID} ${R1} ${R2} > ${ID}.sam
    """
}

process SAMTOOLS {
    // https://github.com/samtools/samtools
    tag "${ID}"
    label 'medium'

    container "quay.io/biocontainers/samtools:1.23.1--ha83d96e_0"

    input:
    tuple val(ID), path(reads), val(size), path(sam_file)

    output:
    tuple val(ID), path(reads), val(size), path("${ID}_stats.tsv")

    script:
    def command="${projectDir}/bin/parse_samtools.py"
    """
    samtools sort -@ ${task.cpus} -o ${ID}.sorted.bam ${sam_file}
    samtools index -@ ${task.cpus} ${ID}.sorted.bam
    samtools stats ${ID}.sorted.bam | grep ^SN | cut -f 2- > ${ID}_stats.tsv
    """
}

process FILTER_SAMTOOLS {
    tag "${ID}"
    label 'small'

    input:
    tuple val(ID), path(reads), val(size), path(sn_stats)

    output:
    tuple val(ID), path(reads), val(size), stdout, emit: samtools_out

    script:
    def command="${projectDir}/bin/parse_samtools.py"
    """
    ${command} ${sn_stats} ${params.min_mapping_rate}
    """
}