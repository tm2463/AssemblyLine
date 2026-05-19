#!/usr/bin/env nextflow

def printHelp() {
    log.info """
Usage:
    nextflow run main.nf --input manifest.csv [options]

Required:
    --input                             Path to input manifest (columns: ID, R1, R2)

Optional:
    --help                              Show this help message

fastp:
    --min_depth                         Default: 30
    --lower_assembly_length             Default: 5500000

sylph:
    --sylph_db                          Path to sylph database (e.g. /path/to/.sylphdb)
    --sylph_taxonomy                    Sylph taxonomy label (default: gtdb_r232)
"""
}