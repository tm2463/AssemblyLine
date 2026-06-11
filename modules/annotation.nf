process BAKTA {
    // https://github.com/oschwengers/bakta
    label 'medium'

    container "quay.io/biocontainers/bakta:1.12.0--pyhdfd78af_0"

    publishDir "${params.outdir}/${ID}", pattern: 'annotation/*.gff3'

    input:
    tuple val(ID), path(contigs)
    path bakta_db

    output:
    path("annotation/*"), emit: bakta_out

    script:
    """
    bakta ${contigs} --db ${bakta_db} --output annotation/ --prefix ${ID} --threads ${task.cpus}
    """
}

process ABRICATE {
    // https://github.com/tseemann/abricate
    label 'medium'

    container "quay.io/biocontainers/abricate:1.4.0--h05cac1d_0"

    publishDir "${params.outdir}/${ID}/abricate"

    input:
    tuple val(ID), path(contigs)

    output:
    path("${ID}_*.tsv"), emit: abricate_out

    script:
    """
    abricate --db plasmidfinder ${contigs} > ${ID}_plasmidfinder.tsv
    abricate --db vfdb ${contigs} > ${ID}_vfdb.tsv
    """
}