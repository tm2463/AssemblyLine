process MLST {
    // https://github.com/tseemann/mlst
    tag "${ID}"
    label 'small'

    container "quay.io/biocontainers/mlst:2.35.0--hdfd78af_0"

    publishDir "${params.outdir}/${ID}"

    input:
    tuple val(ID), path(contigs)

    output:
    path("${ID}_mlst.tsv"), emit: mlst_out

    script:
    """
    mlst --full ${contigs} > ${ID}_mlst.tsv
    """
}