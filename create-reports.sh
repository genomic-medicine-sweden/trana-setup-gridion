#!/bin/bash
if [ -z $1 ]; then
    echo "Usage: create-reports.sh <run-outdir>"
    exit 1
fi
run_outdir=$1

# Make execution more robust
# -e          : Exit immediately on error
# -u          : Treat unset variables as an error
# -o pipefail : Changes the return code of a pipeline to the last command with
#               a non-zero exit code
set -euo pipefail


pixi_path=/data/trana/bin/pixi
reporttool_dir=/data/trana/16s-report
reporttool_path=${reporttool_dir}/make_report.py
report_dir=${run_outdir}/reports

mkdir -p ${report_dir}

neg_control=""
for sample_path in ${run_outdir}/results/*.fastq_rel-abundance.tsv; do
    if [[ ${sample_path} == *NEG* ]]; then
        neg_control_path=${sample_path};
        neg_control=$(basename ${neg_control_path})
        neg_control=${neg_control%_downsampled.fastq_rel-abundance.tsv}
    fi
done

for sample_path in ${run_outdir}/results/*_downsampled.fastq_rel-abundance.tsv; do
    if [[ ${neg_control} == "" ]]; then
        echo "Skipping sample ${sample_path} as negative control is missing";
        continue;
    else
        if [[ ${sample_path} == *NEG* || ${sample_path} == *POS* ]]; then
            echo "Skipping control sample ${sample_path} ..."
            continue
        else
            echo
            echo "--------------------------------------------------------------------------------"
            echo "SAMPLE PATH: ${sample_path}";
            sample_name=$(basename ${sample_path})
            sample_name=${sample_name%_downsampled.fastq_rel-abundance.tsv}
            echo "SAMPLE NAME: ${sample_name}"
            echo "NEG CONTROL: ${neg_control}"
            report_file=${report_dir}/${sample_name}_report.html
            cd ${reporttool_dir};
            ${pixi_path} run python ${reporttool_path} \
                --input-dir ${run_outdir} \
                --sample-name ${sample_name} \
                --neg-control ${neg_control} \
                --alignment-metrics \
                --output-file ${report_file}
        fi
    fi
done
