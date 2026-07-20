process FASTP {
    // https://github.com/opengene/fastp
    tag "${ID}"
    label 'medium'

    container "quay.io/biocontainers/fastp:1.3.3--h43da1c4_0"

    publishDir "${params.outdir}/fastp", pattern: "${ID}.json"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path("${ID}_{1,2}_fastp.fq.gz"), val(size), emit: fastp

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
    tuple val(ID), path("${ID}_fastplong.fq.gz", arity: '1..*'), val(size), emit: fastplong

    script:
    def fastq="${reads[0]}"
    def out="${ID}_fastplong.fq.gz"
    """
    fastplong --thread ${task.cpus} -i ${fastq} -o ${out} -j ${ID}.json
    """ 
}

process FILTER_FASTP {
    // THIS PROCESS IS CURRENTLY UNUSED BUT MAY BE RE-INTRODUCED ALONGSIDE COMMAND SCRIPT IF NEEDED
    // https://pmc.ncbi.nlm.nih.gov/articles/PMC3139241/
    // Total base count >= minimum sequence depth * lower assembly length limit
    // Minimum sequence depth = 30x
    // Lower assembly length limit = 5.5Mbp
    // Total base count = 165Mbp
    label 'small'

    input:
    tuple val(ID), path(reads), val(size), path(fastp_json)

    output:
    tuple val(ID), path(reads), val(size), stdout, emit: fastp_out

    script:
    def command="${projectDir}/bin/pass_fail_fastp.py"
    """
    ${command} ${ID} ${fastp_json} ${params.min_depth} ${params.lower_assembly_length}
    """
}