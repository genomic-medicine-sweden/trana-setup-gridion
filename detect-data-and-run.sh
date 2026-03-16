#!/bin/bash
tranadir=/data/trana
barcodesheetdir=${tranadir}/barcodesheets

runname_prefix="16s_ont_"

export NXF_OFFLINE="true"

run_pipeline=0
installdir=${tranadir}/install
nfdir=${tranadir}/trana
rundir=${tranadir}/run
workdir=${tranadir}/work
outdir=${tranadir}/output
max_samplesize=30000
sleep_seconds_before_start=10

pixi_bin=/data/trana/bin/pixi

for samplesheet_path in /data/${runname_prefix}*/*/*/final_summary_*.txt; do
    data_dir=$(dirname ${samplesheet_path});
    fastq_pass_dir=${data_dir}/fastq_pass
    run_id=$(echo ${samplesheet_path} | cut -d '/' -f 3);
    flowcell_id=$(echo ${samplesheet_path} | cut -d '/' -f 5);
    samplesheet_file=$(basename ${samplesheet_path});

    echo "================================================================================";
    echo "${run_id} / ${flowcell_id} / ${samplesheet_file}";
    echo "--------------------------------------------------------------------------------";
    echo

    done_file=${data_dir}/tranarun.done;
    if [[ -f ${done_file} ]]; then
        echo "[x] This run is already finished by TRANA, so skipping: ${run_id} (Done file: ${done_file} )"
    else
        echo "Sleeping for ${sleep_seconds_before_start} seconds to allow any last files to get created ..."
        sleep ${sleep_seconds_before_start}
        echo

        fastq_pass_dir=${data_dir}/fastq_pass
        if [[ ! -d ${fastq_pass_dir} ]]; then
            echo "[!] No fastq_pass folder in ${data_dir} so not starting TRANA!"
        else
            barcodesheet=${barcodesheetdir}/${run_id}.csv;
            echo "[?] Trana not run on this pipeline, so looking for barcodesheet ...";
            echo
            lock_file=${rundir}/tranarun.lck
            if [[ ! -f ${barcodesheet} ]]; then
                echo "[!] Did not find corresponding barcodesheet ${barcodesheet} so skipping ..."
                echo
            else
                if [[ -f ${lock_file} ]]; then
                    echo "[!] Found lock file due to on-going TRANA run, so skipping (Lock file: ${lock_file} )";
                    echo
                else
                    echo "[>] Found corresponding barcodesheet ${barcodesheet}, so starting analysis ..."
                    echo
                    echo "Creating lock file ${lock_file} ..."
                    echo
                    echo "$(date +%Y%m%d-%H%M%S) Trana run starting for ${data_dir}" > ${lock_file}
                    echo

                    start_timestamp=$(date +%Y%m%d-%H%M%S);
                    run_outdir=${outdir}/${run_id}-${start_timestamp};
                    done_file_local=${run_outdir}/tranarun.done;
                    logfile=${run_outdir}/trana-run-${run_id}-${start_timestamp}.log;

                    if run_pipeline; then
                        echo "[>] $(date '+%Y-%m-%d %H:%M:%S'): Starting analysis for timelimit ${timelimit} of ${casename} with ${max_samplesize} reads"
                        cd ${nfdir} && \
                        ${pixi_bin} run nextflow  \
                            -c ${installdir}/gridion.config \
                            -log ${logfile} \
                            run main.nf \
                            -profile singularity,gridion \
                            --db ${nfdir}/assets/databases/emu_database \
                            --seqtype map-ont \
                            --quality_filtering \
                            --longread_qc_qualityfilter_minlength 1200 \
                            --longread_qc_qualityfilter_maxlength 1800 \
                            --sample_size ${max_samplesize} \
                            --krona_taxonomy_tab ${nfdir}/assets/databases/krona/taxonomy/taxonomy.tab \
                            --merge_fastq_pass ${fastq_pass_dir} \
                            --barcodes_samplesheet ${barcodesheet} \
                            --keep_files \
                            --outdir ${run_outdir} \
                            -w ${workdir} \
                            && echo "TRANA run completed at $(date +%Y%m%d-%H%M%S)" | tee ${done_file} > ${done_file_local};
                        echo "[x] $(date '+%Y-%m-%d %H:%M:%S'): Finished analysis for timelimit ${timelimit} of ${casedir} with ${max_samplesize} reads"
                    else
                        echo "Skipped running pipeline, since run_pipeline is set to false"
                    fi;
                    echo
                    echo "[>] $(date '+%Y-%m-%d %H:%M:%S'): Starting producing 16S report for ${casename} with ${max_samplesize} reads"
                        ./create-reports.sh ${run_outdir}
                    echo "[x] $(date '+%Y-%m-%d %H:%M:%S'): Finishing producing 16S report for ${casename} with ${max_samplesize} reads"
                    echo
                    echo "[x] Removing lock file ${lock_file}"
                    rm ${lock_file}
                    echo
                fi
            fi
        fi
    fi
done |& tee logs/trana-check-$(date +%Y%m%d-%H%M%S).log # &> /dev/null
