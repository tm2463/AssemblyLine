process FASTP {
    // https://github.com/opengene/fastp
    tag "${ID}"
    label 'medium'

    container "quay.io/biocontainers/fastp:1.3.3--h43da1c4_0"

    publishDir "${params.outdir}/fastp", pattern: "${ID}.json"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("${ID}_1_fastp.fq.gz"), path("${ID}_2_fastp.fq.gz"), val(size), path("${ID}.json"), emit: fastp

    script:
    def R1="${reads[0]}"
    def R2="${reads[1]}"
    def out1="${ID}_1_fastp.fq.gz"
    def out2="${ID}_2_fastp.fq.gz"
    """
    fastp --thread ${task.cpus} --in1 ${R1} --in2 ${R2} --out1 ${out1} --out2 ${out2} -j ${ID}.json
    """
}

process FASTPLONG {
    // https://github.com/OpenGene/fastplong/
    tag "${ID}"
    label 'medium'

    container "quay.io/biocontainers/fastplong:0.4.1--h224cc79_0"

    publishDir "${params.outdir}/fastplong", pattern: "${ID}.json"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("${ID}_fastplong.fq.gz"), val(size), path("${ID}.json"), emit: fastplong

    script:
    def fastq="${reads[0]}"
    def out="${ID}_fastplong.fq.gz"
    """
    fastplong --thread ${task.cpus} -i ${fastq} -o ${out} -j ${ID}.json
    """ 
}