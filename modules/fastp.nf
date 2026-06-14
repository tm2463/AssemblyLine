process FASTP {
    // https://github.com/opengene/fastp
    label 'medium'

    container "quay.io/biocontainers/fastp:1.3.3--h43da1c4_0"

    input:
    tuple val(ID), path(R1), path(R2)

    output:
    tuple val(ID), path(out1), path(out2), path("${ID}.json"), emit: fastp

    script:
    out1="${ID}_1_fastp.fq.gz"
    out2="${ID}_2_fastp.fq.gz"
    def command="${projectDir}/bin/pass_fail_fastp.py"
    """
    fastp --thread ${task.cpus} --in1 ${R1} --in2 ${R2} --out1 ${out1} --out2 ${out2} -j ${ID}.json
    """
}

process FASTPLONG {
    // https://github.com/OpenGene/fastplong/
    label 'medium'

    container "quay.io/biocontainers/fastplong:0.4.1--h224cc79_0"

    input:
    tuple val(ID), path(fastq), val(genome_size)

    output:
    tuple val(ID), path(out), val(genome_size), path("${ID}.json"), emit: fastplong

    script:
    out="${ID}_fastplong.fq.gz"
    """
    fastplong -i ${fastq} -o ${out} -j ${ID}.json
    """ 
}

process FILTER_FASTP {
    // https://pmc.ncbi.nlm.nih.gov/articles/PMC3139241/
    // Total base count >= minimum sequence depth * lower assembly length limit
    // Minimum sequence depth = 30x
    // Lower assembly length limit = 5.5Mbp
    // Total base count = 165Mbp
    label 'small'

    input:
    tuple val(ID), path(col2), path(col3), path(fastp_json)

    output:
    tuple val(ID), path(col2), path(col3), stdout, emit: fastp_out

    script:
    def command="${projectDir}/bin/pass_fail_fastp.py"
    """
    ${command} ${ID} ${fastp_json} ${params.min_depth} ${params.lower_assembly_length}
    """
}
