#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR=$HOME/long-read-analysis
DATA_DIR=$PROJECT_DIR/data
READS_DIR=$DATA_DIR/reads
QC_OUTPUT=$DATA_DIR/fastqc_output

mkdir -p "$QC_OUTPUT"


# Run FastQC on the downloaded reads :
fastqc "$READS_DIR"/*.fastq --outdir "$QC_OUTPUT"

echo "=== FastQC complete ==="


