# AssemblyLine

AssemblyLine is a best practise bacterial isolate genome assembly pipeline written in Nextflow. It can handle short, long or hybrid read datasets and performs read QC, assembly, assembly QC and annotation.

## Setup

1. First ensure you have [Nextflow](https://docs.seqera.io/nextflow/install#installation) installed
2. Next ensure you have either [Docker](https://docs.docker.com/engine/install/) or [Singularity](https://docs.sylabs.io/guides/3.0/user-guide/) installed
3. Clone the repo with ``git clone https://github.com/tm2463/AssemblyLine.git``
4. Download reccommended databases by running ``fetch_databases.sh`` included in this repo (optional)

> **NOTE:** If your cluster already has the required databases, you can skip step 4 and simply provide the path to the existing databases

## Usage
Parameters can be passed via the command line or preferably by editing the 'qc.config' file located in this repo.

```
nextflow run main.nf --input <path/to/manifest.csv> [options]
```

## Workflow

There are 3 main subworkflows: **Preprocessing**, **Assembly** and **Annotation**:

**Preprocessing:**
1. Short reads are filtered with [fastp](https://github.com/opengene/fastp), and long reads are filtered with [fastplong](https://github.com/OpenGene/fastplong/)
2. Contamination and coverage is assessed using [Sylph](https://github.com/bluenote-1577/sylph)
3. Short reads are mapped to a reference using [BWA](https://github.com/bwa-mem2/bwa-mem2) and mapping rate is determined using [Samtools](https://github.com/samtools/samtools)
>**INFO:** You can skip preprocessing with the ``--skip_preprocessing`` flag

**Assembly:**

1. Short reads are assembled using [Shovill](https://github.com/tseemann/shovill), long reads are assembled using [Dragonflye](https://github.com/rpetit3/dragonflye), and hybrid reads are assemble using [Unicycler](https://github.com/rrwick/unicycler)
2. Assembly QC is performed using [Quast](https://github.com/ablab/quast), [CheckM2](https://github.com/chklovski/CheckM2) and [FastANI](https://github.com/ParBLiSS/FastANI) (only if a reference is provided).
3. An assembly summary report is compiled and saved to the results directory
> **NOTE:** In short and long-read modes, the assembler each wrapper uses is customisable. For hybrid mode, you can specify which mode you wish Unicyler to run  (see [Options](#options) below)

**Annotation:**

1. Reads are annotated using [Bakta](https://github.com/oschwengers/bakta) and [Abricate](https://github.com/tseemann/abricate)
2. Functional annotations will be perfomed with TDB...
>**COMING SOON:** The ``--skip_assembly`` flag will allow **AssemblyLine** to run as a pure functional annotation pipeline
## Options
You can access all options and parameters by running ``nextflow run <path/to/main.nf> --help``
```
Required:
    --input                             Path to input manifest (columns: ID, R1, R2)
    --sylph_db                          Path to sylph database (e.g. /path/to/.sylphdb)
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
```
### Databases
For more details on the required databases, please open the following links in a new tab:
- Sylph [link](https://sylph-docs.github.io/pre%E2%80%90built-databases/)
- CheckM2 [link](https://github.com/chklovski/CheckM2#Databases)
- Bakta database [link](https://github.com/oschwengers/bakta#database)

### TODO:
1. Implement functional annotation processes
2. Remove sylph-tax file download process, adding download link to fetch_databases.sh
3. Bakta DB requires manually updating in order to be compatible