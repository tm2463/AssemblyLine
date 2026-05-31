process FASTP {
    // https://github.com/opengene/fastp
    label 'medium'

    container "quay.io/biocontainers/fastp:1.3.3--h43da1c4_0"
    
    publishDir "${params.outdir}/fastp", pattern: '*.json'

    input:
    tuple val(ID), path(R1), path(R2)

    output:
    tuple val(ID), path(out1), path(out2), path("${ID}.json")

    script:
    out1="${ID}_1_fastp.fq.gz"
    out2="${ID}_2_fastp.fq.gz"
    def command="${projectDir}/bin/pass_fail_fastp.py"
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
    label 'small'

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
    label 'medium'

    container "quay.io/biocontainers/sylph:0.9.0--ha6fb395_0"

    publishDir "${params.outdir}/${ID}", pattern: '*_sylph_profile.tsv'

    input:
    tuple val(ID), path(R1), path(R2)
    path(sylph_db)

    output:
    tuple val(ID), path(R1), path(R2), path("${ID}_sylph_profile.tsv"), emit: sylph_out

    script:
    """
    sylph sketch -t ${task.cpus} -1 ${R1} -2 ${R2} -d ${ID}_sketch
    sylph profile -t ${task.cpus} ${sylph_db} ${ID}_sketch/*.sylsp > ${ID}_sylph_profile.tsv
    """
}

process SYLPH_TAX_FILE {
    label 'small'

    container "quay.io/biocontainers/sylph-tax:1.9.0--pyhdfd78af_0"

    output:
    path("${params.sylph_taxonomy}_metadata.tsv.gz"), emit: tax

    script:
    """
    sylph-tax download --download-to .
    """
}

process SYLPH_TAX {
    // https://www.nature.com/articles/s41467-021-24128-2
    // At least 95% ANI, 98% sequence abundance and at least (30 | ${params.min_depth}) effective coverage
    label 'small'

    publishDir "${params.outdir}/${ID}", pattern: '${ID}*.sylphmpa'

    container "quay.io/biocontainers/sylph-tax:1.9.0--pyhdfd78af_0"

    input:
    tuple val(ID), path(R1), path(R2), path(sylph_profile), path(tax_file)

    output:
    tuple val(ID), path(R1), path(R2), stdout

    script:
    """
    sylph-tax taxprof ${sylph_profile} -t ${tax_file} -o ${ID} 1>&2

    awk 'NF' ${ID}*.sylphmpa | tail -n 1 \
        | awk -F'\t' 'BEGIN{OFS="\\t"} \$2 > 98 && \$3 > 98 && \$4 > 95 && \$5 > ${params.min_depth} {print \$1, \$2, \$3, \$4, \$5}' \
        > ${ID}_tax.tsv

    if [ -s ${ID}_tax.tsv ]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
    """
}

process BWA {
    // https://github.com/bwa-mem2/bwa-mem2
    label 'medium'

    container "quay.io/biocontainers/bwa-mem2:2.3--he70b90d_0"

    input:
    tuple val(ID), path(R1), path(R2)

    output:
    tuple val(ID), path(R1), path(R2), path("${ID}.sam")

    script:
    reference = "${projectDir}/data/GCF_000006765.1_ASM676v1_genomic.fna.gz"
    """
    bwa-mem2 index -p ${ID} ${reference}
    bwa-mem2 mem -t ${task.cpus} ${ID} ${R1} ${R2} > ${ID}.sam
    """
}
