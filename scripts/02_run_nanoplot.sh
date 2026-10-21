#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR=$HOME/long-read-analysis
DATA_DIR=$PROJECT_DIR/data
READS_DIR=$DATA_DIR/reads
NP_OUTPUT=$DATA_DIR/nanoplot_output

mkdir -p "$DATA_DIR/nanoplot_output"

# Run NanoPlot on the downloaded reads :
NanoPlot --fastq "$READS_DIR"/*.fastq -o "$NP_OUTPUT"

# Run FastQC on the downloaded reads :
# fastqc "$READS_DIR"/*.fastq --outdir "$QC_OUTPUT"

echo "=== NanoPlot complete ==="
