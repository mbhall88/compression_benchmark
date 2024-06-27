#!/usr/bin/env bash
set -eu

JOB_NAME="snakemake_master_process."$(date "+%s")
LOG_DIR="logs"

if [[ ! -d "$LOG_DIR" ]]; then
    echo "Error: Log directory $LOG_DIR does not exist"
    exit 1
fi

MEMORY="2G"
TIME="${TIME:-3h}"
THREADS=2
PROFILE="slurm.punim2009"
BINDS="/data/scratch/projects/punim2009/"
SINGULARITY_ARGS="-B $BINDS"
DEFAULT_TMP="tmpdir='/tmp'"
CMD="snakemake --profile $PROFILE --default-resources \"$DEFAULT_TMP\" --rerun-incomplete --local-cores $THREADS $* --singularity-args '$SINGULARITY_ARGS'"

ssubmit -t "$TIME" -m "$MEMORY" -o "$LOG_DIR"/"$JOB_NAME".o \
    -e "$LOG_DIR"/"$JOB_NAME".e "$JOB_NAME" "$CMD" -- -c "$THREADS" -p sapphire
