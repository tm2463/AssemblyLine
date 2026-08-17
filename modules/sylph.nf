process SYLPH {
    // https://github.com/bluenote-1577/sylph
    tag "${ID}"
    label 'medium'

    container "quay.io/biocontainers/sylph:0.9.0--ha6fb395_0"

    input:
    tuple val(ID), path(reads), val(genome_size)
    path(sylph_db)

    output:
    tuple val(ID), path(reads), val(genome_size), path("${ID}_sylph_profile.tsv"), emit: sylph_out

    script:
    def n = reads.size()
    def profile = "sylph profile -t ${task.cpus} ${sylph_db} ${ID}_sketch/*.sylsp > ${ID}_sylph_profile.tsv"
    if (n == 2) {
        // short paired-end only
        def R1 = reads[0]
        def R2 = reads[1]
        """
        sylph sketch -t ${task.cpus} -1 ${R1} -2 ${R2} -d ${ID}_sketch
        ${profile}
        """
    } else {
        // long reads only
        def long_fastq = reads[0]
        """
        sylph sketch -t ${task.cpus} -d ${ID}_sketch ${long_fastq}  
        ${profile}
        """
    }
}

process SYLPH_TAX {
    // https://www.nature.com/articles/s41467-021-24128-2
    // At least 98% sequence abundance
    tag "${ID}"
    label 'small'

    publishDir "${params.outdir}/${ID}", pattern: '*.sylphmpa'
    publishDir "${params.outdir}/failed_samples", pattern: "${ID}.fail"

    container "quay.io/biocontainers/sylph-tax:1.9.0--pyhdfd78af_0"

    input:
    tuple val(ID), path(reads), val(genome_size), path(sylph_profile)

    output:
    tuple val(ID), path(reads), val(genome_size), path("*.sylphmpa"), stdout, emit: sylph_tax
    path("${ID}.fail"), optional: true

    script:
    def tax_file = file(params.sylph_tax_file, checkIfExists: true)
    """
    sylph-tax taxprof ${sylph_profile} -t ${tax_file} 1>&2

    RESULT=\$(awk 'NF' ${ID}*.sylphmpa | tail -n 1 \
        | awk -F'\t' '\$2 > 98 {found=1} END {print (found ? "PASS" : "FAIL")}')

    if [ "\${RESULT}" == "FAIL" ]; then
        echo "${ID} failed sylph-tax filter: final row did not meet sequence abundance threshold (>98)" > ${ID}.fail
    fi

    printf '%s' "\${RESULT}"
    """
}
