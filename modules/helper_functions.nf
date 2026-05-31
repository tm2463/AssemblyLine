#!/usr/bin/env nextflow

def printHelp() {
    log.info """
Usage:
    nextflow run main.nf --input manifest.csv [options]

Required:
    --input                             Path to input manifest (columns: ID, R1, R2)

Optional:
    --help                              Show this help message

Fastp:
    --min_depth                         Default: 30
    --lower_assembly_length             Default: 5500000

Sylph:
    --sylph_db                          Path to sylph database (e.g. /path/to/.sylphdb)
    --sylph_taxonomy                    Sylph taxonomy label (Default: gtdb_r232)

Assembly:
    --min_contig_length                 Default: 500

QC:
    --checkm2_db                        Path to checkm2 database (e.g. /path/to/.dmnd)
"""
}