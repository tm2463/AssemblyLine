#!/usr/bin/env nextflow

def printHelp() {
    log.info """
Usage:
    nextflow run main.nf --input manifest.csv [options]

Required:
    --input                             Path to input manifest (columns: ID, R1, R2)
    --reference                         Path to reference genome for QC stages
    --sylph_db                          Path to sylph database (e.g. /path/to/.sylphdb)
    --checkm2_db                        Path to checkm2 database (e.g. /path/to/.dmnd)
    --bakta_db                          Path to bakta database (e.g. /path/to/database)

Modes:
    --mode                              Options: short, long, hybrid (default: short)
    --skip_preprocessing                Skip preprocessing step (default: false)

Other Options:
    --min_depth                         Minimum read coverage (default: 30)
    --lower_assembly_length             Lower bound for the target assembly length (default: 5500000)
    --target_genome_size                Assembly QC fails if genome size ±20% of target size (default: 6250000)
    --min_mapping_rate                  Threshold proportion of reads needing to map to reference during QC (default: 0.8)
    --min_contig_length                 Min contig length to be included in final assembly (default: 500)
    --ref_ani                           Threshold ANI percentage for final assembly compared to reference (default: 95)
    --completeness                      Threshold CheckM2 completeness score to pass QC (default: 99)
    --contamination                     Threshold CheckM2 contamination score to pass QC (default: 5)
    --target_gc_content                 Assembly QC fails if genome GC content ±10% of target amount (default: 0.66)

Optional:
    --help                              Show this help message
    --sylph_taxonomy                    Sylph taxonomy label (Default: gtdb_r232)
"""
}

def validateParams() {
    if (!params.input) {
        log.error "Error: --input parameter is required."
        printHelp()
        exit 1
    }

    if (!file(params.input).exists()) {
        log.error "Error: Input manifest file '${params.input}' does not exist."
        exit 1
    }

    if (params.mode && !['short', 'long', 'hybrid'].contains(params.mode)) {
        log.error "Error: Invalid value for --mode. Allowed values are 'short', 'long', or 'hybrid'."
        exit 1
    }
}

def validateManifest() {
    def manifestFile = file(params.input)
    if (!manifestFile.exists()) {
        log.error "Error: Manifest file '${params.input}' does not exist."
        exit 1
    }

    def requiredHeaders = [
        short:  ['ID', 'R1', 'R2'],
        long:   ['ID', 'long_fastq', 'genome_size'],
        hybrid: ['ID', 'R1', 'R2', 'long_fastq']
    ]

    def headers = manifestFile.readLines().first().split(',')*.trim()
    def missing = requiredHeaders[params.mode]?.findAll { !headers.contains(it) }

    if (missing) {
        log.error "Error: Manifest is missing required headers for read_type '${params.read_type}': ${missing.join(', ')}"
        exit 1
    }
}

def setInputChannel() {
    input_ch = Channel
        .fromPath(params.input)
        .splitCsv(header: true)

    if (params.mode == 'short') {
        input_ch = input_ch.map { row ->
            def ID = row.ID
            def R1 = file(row.R1, checkIfExists: true)
            def R2 = file(row.R2, checkIfExists: true)
            tuple(ID, [R1, R2], null)
        }
    } else if (params.mode == 'long') {
        input_ch = input_ch.map { row ->
            def ID = row.ID
            def long_fastq = file(row.long_fastq, checkIfExists: true)
            def genome_size = row.genome_size ? row.genome_size.toInteger() : null
            tuple(ID, [long_fastq], genome_size)
        }
    } else if (params.mode == 'hybrid') {
        input_ch = input_ch.map { row ->
            def ID = row.ID
            def R1 = file(row.R1, checkIfExists: true)
            def R2 = file(row.R2, checkIfExists: true)
            def long_fastq = file(row.long_fastq, checkIfExists: true)
            def genome_size = row.genome_size ? row.genome_size.toInteger() : null
            tuple(ID, [R1, R2, long_fastq], genome_size)
        }
    }
    return input_ch
}
