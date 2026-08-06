process SHOVILL {
    // https://github.com/tseemann/shovill
    tag "${ID}"
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
    shovill --outdir results --R1 ${R1} --R2 ${R2} --cpus ${task.cpus} --minlen ${params.min_contig_length} --assembler ${params.short_assembler}
    mv results/contigs.fa "${ID}_contigs.fa"
    """
}