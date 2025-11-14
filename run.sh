#!/bin/bash
installdir=$(pwd)
nfdir=/home/grid/opt/trana
workdir=/data/trana/work
start_timestamp=$(date +%Y%m%d-%H%M%S)
outdir=/data/trana/results/trana_run_${start_timestamp}
cd ${nfdir} && \
pixi run nextflow  \
    -c ${installdir}/gridion.config \
    -log $(pwd)/nextflow.log \
    run main.nf \
    -profile docker,gridion \
    --outdir ${outdir} \
    --db $(pwd)/assets/databases/emu_database \
    --krona_taxonomy_tab $(pwd)/assets/databases/krona/taxonomy/taxonomy.tab \
    --input https://raw.githubusercontent.com/genomic-medicine-sweden/test-datasets/refs/heads/16s/samplesheet.csv \
    -w ${workdir}
