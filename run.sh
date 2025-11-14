#!/bin/bash
nextflow  \
    -log $(pwd)/nextflow.log \
    run main.nf \
    -profile docker,test \
    --outdir results \
    --db $(pwd)/assets/databases/emu_database \
    --input https://raw.githubusercontent.com/genomic-medicine-sweden/test-datasets/refs/heads/16s/samplesheet.csv
