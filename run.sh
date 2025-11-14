#!/bin/bash
inst_dir=$(pwd)
start_timestamp=$(date +%Y%m%d-%H%M%S)
outdir=/data/trana-output/${start_timestamp}
cd /home/grid/opt/trana && \
pixi run nextflow  \
    -c ${inst_dir}/gridion.config \
    -log $(pwd)/nextflow.log \
    run main.nf \
    -profile docker,gridion \
    --outdir ${outdir} \
    --db $(pwd)/assets/databases/emu_database \
    --input https://raw.githubusercontent.com/genomic-medicine-sweden/test-datasets/refs/heads/16s/samplesheet.csv
