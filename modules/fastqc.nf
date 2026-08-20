process FASTQC {
    tag "${ID}"
    label 'small'

    container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"

    publishDir "${params.outdir}/fastqc", pattern: "*.html"

    input:
    tuple val(ID), path(reads), val(size)

    output:
    tuple val(ID), path(reads), val(size), path("*.zip"), emit: zip
    tuple val(ID), path("*.html"), emit: html

    script:
    def R1="${reads[0]}"
    def R2="${reads[1]}"
    """
    fastqc ${R1} ${R2} --threads ${task.cpus}
    """
}

process FILTER_FASTQC {
    tag "${ID}"
    label 'small'

    input:
    tuple val(ID), path(reads), val(size), path(fastqc_zip)
    path(fastqc_pass_criteria)

    output:
    tuple val(ID), path(reads), val(size), stdout, emit: fastqc_out

    script:
    def read_1="${fastqc_zip[0]}"
    def read_2="${fastqc_zip[1]}"
    def command="${projectDir}/bin/pass_fail_fastqc.py"
    """
    unzip ${read_1} 1>&2
    unzip ${read_2} 1>&2

    ${command} \
        --summary_files */summary.txt \
        --pass_criteria_json ${fastqc_pass_criteria}
    """
}