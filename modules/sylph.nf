process SYLPH {
    // https://github.com/bluenote-1577/sylph
    label 'medium'

    container "quay.io/biocontainers/sylph:0.9.0--ha6fb395_0"

    publishDir "${params.outdir}/sylph/${ID}", pattern: '*_sylph_profile.tsv'

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

    publishDir "${params.outdir}/sylph/${ID}", pattern: '*.sylphmpa'

    container "quay.io/biocontainers/sylph-tax:1.9.0--pyhdfd78af_0"

    input:
    tuple val(ID), path(R1), path(R2), path(sylph_profile), path(tax_file)

    output:
    tuple val(ID), path(R1), path(R2), path("*.sylphmpa"), stdout

    script:
    def filter = "\$2 > 98 && \$3 > 98 && \$4 > 95 && \$5 > ${params.min_depth}"
    """
    sylph-tax taxprof ${sylph_profile} -t ${tax_file} 1>&2

    awk 'NF' ${ID}*.sylphmpa | tail -n 1 \
        | awk -F'\t' '${filter} {found=1} END {print (found ? "PASS" : "FAIL")}'
    """
}
