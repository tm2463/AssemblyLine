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
    --skip_preprocessing                Skip preprocessing step (default: false)
    --mode                              Options: short, long, hybrid (default: short)

Fastp:
    --min_depth                         Default: 30
    --lower_assembly_length             Default: 5500000

Mapping:
    --min_mapping_rate                  Minimum fraction of reads aligning to reference (Default: 0.8)

Assembly:
    --min_contig_length                 Default: 500

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
