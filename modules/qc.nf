process QUAST {
    // https://github.com/ablab/quast
    label 'small'

    container "quay.io/biocontainers/quast:5.3.0--py313pl5321h5ca1c30_2"

    publishDir "${params.outdir}/quast", overwrite: true

    input:
    val IDS
    path fastas, stageAs: 'fastas/*'

    output:
    val IDS

    script:
    """
    quast.py fastas/* -o quast --no-plot --no-html --threads ${task.cpus}
    """
}