#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR=~/intro-to-seq/project
READS_DIR=$PROJECT_DIR/reads
mkdir -p "$PROJECT_DIR/fastqc_output"
QC_OUTPUT="$PROJECT_DIR/fastqc_output"

# Run FastQC on the downloaded reads :
fastqc "$READS_DIR"/*.fastq --outdir "$QC_OUTPUT"

echo "=== FastQC complete ==="