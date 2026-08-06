process UNICYCLER {
    // https://github.com/rrwick/unicycler
    tag "${ID}"
    label 'large'

    container 'quay.io/biocontainers/unicycler:0.5.1--py312hdcc493e_5'

    publishDir "${params.outdir}/${ID}"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("${ID}_contigs.fa")

    script:
    def R1="${reads[0]}"
    def R2="${reads[1]}"
    def long_fastq="${reads[2]}"
    """
    mkdir -p unicycler_output

    unicycler \
        -1 ${R1} \
        -2 ${R2} \
        -l ${long_fastq} \
        -o unicycler_output \
        -t ${task.cpus} \
        --min_fasta_length ${params.min_contig_length} \
        --mode ${params.unicycler_mode}

    mv unicycler_output/assembly.fasta "${ID}_contigs.fa"
    """
}