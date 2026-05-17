process FASTP {
    // https://github.com/opengene/fastp
    cpus 8
    memory 8.GB

    container "quay.io/biocontainers/fastp:1.3.3--h43da1c4_0"

    input:
    tuple val(ID), path(R1), path(R2)

    output:
    tuple val(ID), path(out1), path(out2), emit: trimmed_fastqs

    script:
    out1="fastp-${ID}_1.fq.gz"
    out2="fastp-${ID}_2.fq.gz"
    """
    fastp --thread ${task.cpus} --in1 ${R1} --in2 ${R2} --out1 ${out1} --out2 ${out2} -j ${ID}.json
    """
}

// process SYLPH {
//     // https://github.com/bluenote-1577/sylph
//     cpus 8
//     memory 8.GB

//     container "quay.io/biocontainers/sylph:0.9.0--ha6fb395_0"
// }

// process BWA {
//     // https://github.com/bwa-mem2/bwa-mem2
//     cpus 8
//     memory 8.GB

//     container "quay.io/biocontainers/bwa-mem2:2.3--he70b90d_0"
// }
