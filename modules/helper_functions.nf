#!/usr/bin/env nextflow

def printHelp() {
    log.info """
Usage:
    nextflow run main.nf --input manifest.csv [options]

Parameters can be passed via the command line or preferably by editing the 'qc.config' file.

Required:
    --input                             Path to input manifest (columns: ID, R1, R2)
    --sylph_db                          Path to sylph database (e.g. /path/to/.sylphdb)
    --sylph_tax_file                    Path to sylph-tax database (e.g. /path/to/gtdb_r232_metadata.tsv.gz)
    --checkm2_db                        Path to checkm2 database (e.g. /path/to/.dmnd)
    --bakta_db                          Path to bakta database (e.g. /path/to/database)

Modes:
    --mode                              Options: short, long, hybrid (default: short)
    --skip_preprocessing                Skip preprocessing step (default: false)

Other Options:
    --reference                         Path to reference genome for QC stages
    --min_depth                         Minimum read coverage (default: 30)
    --lower_assembly_length             Lower bound for the target assembly length (default: 5500000)
    --target_genome_size                Assembly QC fails if genome size ±20% of target size (default: 6250000)
    --min_mapping_rate                  Threshold proportion of reads needing to map to reference during QC (default: 0.8)
    --min_contig_length                 Min contig length to be included in final assembly (default: 500)
    --ref_ani                           Threshold ANI percentage for final assembly compared to reference (default: 95)
    --completeness                      Threshold CheckM2 completeness score to pass QC (default: 99)
    --contamination                     Threshold CheckM2 contamination score to pass QC (default: 5)
    --target_gc_content                 Assembly QC fails if genome GC content ±10% of target amount (default: 0.66)

Assembly Options:
    --short_assembler                   Options: spades, skesa, megahit (default: spades)
    --long_assembler                    Options: flye, raven, miniasm (default: flye)
    --unicycler_mode                    Options: conservative, normal, bold (default: normal)

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

    def validShortAssemblers = ["spades", "skesa", "megahit"]
    if (!(params.short_assembler in validShortAssemblers)) {
        log.error "Error: Invalid short read assembler, please choose: spades, skesa or megahit"
        exit 1
    }

    def validLongAssemblers = ["flye", "raven", "miniasm"]
    if (!(params.long_assembler in validLongAssemblers)) {
        log.error "Error: Invalid long read assembler, please choose: flye, raven or miniasm"
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
        short: ['ID', 'R1', 'R2'],
        long: ['ID', 'long_fastq', 'genome_size'],
        hybrid: ['ID', 'R1', 'R2', 'long_fastq', 'genome_size']
    ]

    def headers = manifestFile.readLines().first().split(',')*.trim()
    def missing = requiredHeaders[params.mode]?.findAll { !headers.contains(it) }

    if (missing) {
        log.error "Error: Manifest is missing required headers for read_type '${params.read_type}': ${missing.join(', ')}"
        exit 1
    }
}

def setInputChannel() {
    def rows = Channel
        .fromPath(params.input)
        .splitCsv(header: true)

    def asFile = { path -> file(path, checkIfExists: true) }
    def parseSize = { row  -> row.genome_size ? row.genome_size.toInteger() : null }

    switch (params.mode) {
        case 'short':
            return rows.map { row ->
                tuple(row.ID, [asFile(row.R1), asFile(row.R2)], null)
            }
        case 'long':
            return rows.map { row ->
                tuple(row.ID, [asFile(row.long_fastq)], parseSize(row))
            }
        case 'hybrid':
            return rows.map { row ->
                short_reads: tuple(row.ID, [asFile(row.R1), asFile(row.R2), asFile(row.long_fastq)], parseSize(row))
            }
        default:
            error "Unknown params.mode: ${params.mode}"
    }
}
