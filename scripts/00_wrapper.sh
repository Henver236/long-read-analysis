#!/usr/bin/env bash

set -euo pipefail

# Let's set the variables for the project directory and the reads directory.
PROJECT_DIR=~/long-read-analysis
SCRIPTS_DIR="$PROJECT_DIR/scripts"

# Activate the conda environment with tools for analysis.
conda activate long-read-analysis

### 01_download_reads.sh ######################################
bash "$SCRIPTS_DIR"/01_download_reads.sh

### 02_run_fastqc.sh ##########################################
bash "$SCRIPTS_DIR"/02_run_fastqc.sh
# bash "$SCRIPTS_DIR"/02_run_fastqc_copy.sh

### 02_run_nanoplot.sh ########################################
bash "$SCRIPTS_DIR"/02_run_nanoplot.sh

### 03_trim_reads.sh ##########################################
#bash "$SCRIPTS_DIR"/03_trim_reads.sh

### 04_run_fastqc_trimmed.sh ##################################
#bash "$SCRIPTS_DIR"/04_run_fastqc_trimmed.sh

### 05_download_ecoli_reference.sh ############################
#bash "$SCRIPTS_DIR"/05_download_ecoli_reference.sh


