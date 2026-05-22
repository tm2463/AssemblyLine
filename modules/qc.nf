process QUAST {
    // https://github.com/ablab/quast
    label 'small'

    container "quay.io/biocontainers/quast:5.3.0--py313pl5321h5ca1c30_2"

    publishDir "${params.outdir}/quast", pattern: '*_quast_report.tsv'
}