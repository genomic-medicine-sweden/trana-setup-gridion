#!/bin/bash
tranadir=/data/trana
export NXF_OFFLINE="true"

# Change the below line to 0 to test only the report generation
installdir=${tranadir}/install
nfdir=${tranadir}/trana
rundir=${tranadir}/run
workdir=${tranadir}/work
outdir=${tranadir}/output
max_samplesize=30000
sleep_seconds_before_start=1

pixi_bin=/data/trana/bin/pixi

# Ensure the logs directory exists
mkdir -p logs

# Run the main loop
samplesheet=$1
run_id=$2
if [[ ${samplesheet} == "" || ${run_id} == "" ]]; then
    echo "Usage: ./run-custom.sh <samplesheet.csv> <run-id>"
    exit 1;
fi

# Make execution more robust
# -e          : Exit immediately on error
# -u          : Treat unset variables as an error
# -o pipefail : Changes the return code of a pipeline to the last command with
#               a non-zero exit code
set -euo pipefail

start_timestamp=$(date +%Y%m%d-%H%M%S);
run_outdir=${outdir}/${run_id}-${start_timestamp};
mkdir -p ${run_outdir}

logfile=${run_outdir}/trana-run-${run_id}-${start_timestamp}.log;

echo "$(date +%Y%m%d-%H%M%S) Trana run starting for samplesheet ${samplesheet}" | tee -a ${logfile}
echo "[>] $(date '+%Y-%m-%d %H:%M:%S'): Starting analysis of ${run_id} with ${max_samplesize} reads" | tee -a ${logfile}

cd ${nfdir} && \
${pixi_bin} run nextflow  \
    -c ${installdir}/gridion.config \
    -log ${logfile} \
    run main.nf \
    -resume \
    -profile singularity,gridion \
    --input ${samplesheet} \
    --db ${nfdir}/assets/databases/emu_database \
    --seqtype "lr:hq" \
    --quality_filtering \
    --longread_qc_qualityfilter_minlength 1200 \
    --longread_qc_qualityfilter_maxlength 1800 \
    --downsample_n_reads ${max_samplesize} \
    --krona_taxonomy_tab ${nfdir}/assets/databases/krona/taxonomy/taxonomy.tab \
    --keep_files \
    --outdir ${run_outdir} \
    -w ${workdir} | tee -a ${logfile} \
    && echo "TRANA run completed at $(date +%Y%m%d-%H%M%S)" | tee -a ${done_file} > ${done_file_local};

echo "[x] $(date '+%Y-%m-%d %H:%M:%S'): Finished analysis for ${run_id} with ${max_samplesize} reads" | tee -a ${logfile}
echo "[>] $(date '+%Y-%m-%d %H:%M:%S'): Starting producing 16S report for ${run_id} with ${max_samplesize} reads" | tee -a ${logfile}
    cd ${rundir};
    ./create-reports.sh ${run_outdir};
echo "[x] $(date '+%Y-%m-%d %H:%M:%S'): Finishing producing 16S report for ${run_id} with ${max_samplesize} reads" | tee -a ${logfile}
