#!/usr/bin/env bash

mkdir databases && cd databases

# sylph db
wget http://faust.compbio.cs.cmu.edu/sylph-stuff/gtdb-r232-c1000-dbv1.syldb

# checkm2 db
wget https://zenodo.org/records/14897628/files/checkm2_database.tar.gz?download=1
tar -xvzf "checkm2_database.tar.gz?download=1" && rm checkm2_database.tar.gz?download=1
mv CheckM2_database/uniref100.KO.1.dmnd uniref100.KO.1.dmnd && rm -r CheckM2_database
rm CONTENTS.json

# bakta db
wget https://zenodo.org/records/14916843/files/db-light.tar.xz?download=1
tar -xvJf "db-light.tar.xz?download=1" && rm db-light.tar.xz?download=1
