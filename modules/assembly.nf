process SHOVILL {
    // https://github.com/tseemann/shovill
    label 'large'

    container "quay.io/biocontainers/shovill:1.4.2--hdfd78af_0"

    publishDir "${params.outdir}/${ID}"

    input:
    tuple val(ID), path(R1), path(R2)

    output:
    tuple val(ID), path("${ID}_contigs.fa"), emit: shovill_out

    script:
    """
    shovill --outdir ${params.outdir} --R1 ${R1} --R2 ${R2} --cpus ${task.cpus} --minlen ${params.min_contig_length}
    mv results/contigs.fa "${ID}_contigs.fa"
    """
}