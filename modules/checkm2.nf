process CHECKM2 {
    // https://github.com/chklovski/CheckM2
    tag "${ID}"
    label 'medium'

    container "quay.io/biocontainers/checkm2:1.1.0--pyh7e72e81_1"

    input:
    tuple val(ID), path(fasta)
    path checkm2_db

    output:
    tuple val(ID), path("${ID}_checkm2.tsv"), emit: checkm2_out

    script:
    """
    checkm2 predict --input ${fasta} --output-directory checkm2 --threads ${task.cpus} -x .fa --database_path ${checkm2_db}
    mv checkm2/quality_report.tsv ${ID}_checkm2.tsv
    """
}