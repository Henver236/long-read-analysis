#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR=~/intro-to-seq/project
TRIM_DIR=$PROJECT_DIR/trimmed
mkdir -p "$PROJECT_DIR/fastqc_output_trimmed"
QC_OUTPUT="$PROJECT_DIR/fastqc_output_trimmed"

echo "=== FastQC on trimmed reads started ==="

# Run FastQC on the downloaded reads :
fastqc "$TRIM_DIR"/*.fastq --outdir "$QC_OUTPUT"

echo "Done → $QC_OUTPUT"
echo "=== FastQC on trimmed reads complete ==="