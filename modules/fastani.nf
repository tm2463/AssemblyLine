process FASTANI {
    // https://github.com/ParBLiSS/FastANI
    tag "${ID}"
    label 'small'

    container "quay.io/biocontainers/fastani:1.34--hb66fcc3_7"

    input:
    tuple val(ID), path(fasta)
    path(ref)

    output:
    tuple val(ID), path("${ID}.out"), emit: fastani_out

    script:
    """
    fastANI -q ${fasta} -r ${ref} -o ${ID}.out
    """
}