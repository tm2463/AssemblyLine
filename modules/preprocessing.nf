process FASTP {
    // https://github.com/opengene/fastp
    cpus 8
    memory 8.GB

    container "quay.io/biocontainers/fastp:1.3.3--h43da1c4_0"
    
    publishDir "${params.outdir}/fastp", mode: 'copy', pattern: '*.json'

    input:
    tuple val(ID), path(R1), path(R2)

    output:
    tuple val(ID), path(out1), path(out2), path("${ID}.json")

    script:
    out1="${ID}_1_fastp.fq.gz"
    out2="${ID}_2_fastp.fq.gz"
    """
    fastp --thread ${task.cpus} --in1 ${R1} --in2 ${R2} --out1 ${out1} --out2 ${out2} -j ${ID}.json
    """
}

process FILTER_FASTP {
    // https://pmc.ncbi.nlm.nih.gov/articles/PMC3139241/
    // Total base count >= minimum sequence depth * lower assembly length limit
    // Minimum sequence depth = 30x
    // Lower assembly length limit = 5.5Mbp
    // Total base count = 165Mbp
    cpus 1
    memory 1.GB

    input:
    tuple val(ID), path(R1), path(R2), path(fastp_json)

    output:
    tuple val(ID), path(R1), path(R2), stdout, emit: fastp_out

    script:
    def command="${projectDir}/bin/pass_fail_fastp.py"
    """
    ${command} ${ID} ${fastp_json} ${params.min_depth} ${params.lower_assembly_length}
    """
}

process SYLPH {
    // https://github.com/bluenote-1577/sylph
    cpus 8
    memory 8.GB

    container "quay.io/biocontainers/sylph:0.9.0--ha6fb395_0"

    publishDir "${params.outdir}/sylph", mode: 'copy', pattern: '*_sylph_profile.tsv'

    input:
    tuple val(ID), path(R1), path(R2)

    output:
    tuple val(ID), path(R1), path(R2), path("${ID}_sylph_profile.tsv")

    script:
    """
    sylph sketch -t ${task.cpus} -1 ${R1} -2 ${R2} -d ${ID}_sketch
    sylph profile -t ${task.cpus} ${params.sylph_db} ${ID}_sketch/*.sylsp > ${ID}_sylph_profile.tsv
    """
}

// process BWA {
//     // https://github.com/bwa-mem2/bwa-mem2
//     cpus 8
//     memory 8.GB

//     container "quay.io/biocontainers/bwa-mem2:2.3--he70b90d_0"
// }
