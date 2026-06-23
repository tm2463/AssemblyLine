#!/usr/bin/env bash

mkdir short_read && cd short_read
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR120/ERR12024995/p78_d1_A9_R2.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR120/ERR12024988/p50_d1_A8_R1.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR120/ERR12024988/p50_d1_A8_R2.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR120/ERR12024990/p80_d1_F5_R1.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR120/ERR12024990/p80_d1_F5_R2.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR120/ERR12024995/p78_d1_A9_R1.fastq.gz

cd ../
mkdir long_read && cd long_read
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR173/ERR17322606/barcode10.filtered.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR173/ERR17322597/barcode01.filtered.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR173/ERR17322608/barcode12.filtered.fastq.gz