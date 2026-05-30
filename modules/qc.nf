process CHECKM2 {
    // https://github.com/chklovski/CheckM2
    label 'medium'

    container "quay.io/biocontainers/checkm2:1.1.0--pyh7e72e81_1"

    input:
    path fastas, stageAs: 'fastas/*'
    path checkm2_db

    output:
    path "checkm2/quality_report.tsv"

    script:
    """
    checkm2 predict --input fastas --output-directory checkm2 --threads ${task.cpus} -x .fa --database_path ${checkm2_db}
    """
}

process GUNC {
    // https://github.com/grp-bork/gunc
    label 'medium'

    container "quay.io/biocontainers/gunc:1.1.1--pyhdfd78af_0"

    input:
    path fastas, stageAs: 'fastas/*'
    path gunc_db

    output:
    path "GUNC.*maxCSS_level.tsv"

    script:
    """
    gunc run --input_dir fastas/ --db_file ${gunc_db} --threads ${task.cpus}
    """
}