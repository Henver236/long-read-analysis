#!/usr/bin/env bash

PROJECT_DIR="$HOME/long-read-analysis"
DATA_DIR="$PROJECT_DIR/data"
READS_DIR="$DATA_DIR/reads"
REFERENCE_DIR="$DATA_DIR/reference"

# Download the long reads 
cd "$DATA_DIR"

wget https://ngs-introduction-training.s3.eu-central-1.amazonaws.com/project2.tar.gz
tar -xvf project2.tar.gz
rm project2.tar.gz

mv $DATA_DIR/project2/* $DATA_DIR

# Now, let's unzip the fastq files and move them to the reads directory

gunzip $READS_DIR/*.fastq.gz

# To count the number of reads in a fastq file by counting the number of lines and dividing by four.
## forward read & reverse read
echo $(cat $READS_DIR/*.fastq | wc -l)/4 | bc

# Count the number of reads in the forward and reverse files separately:
FORWARD=$(( $(wc -l < "$READS_DIR/*.fastq" | grep "_1" | wc -l) / 4 ))
REVERSE=$(( $(wc -l < "$READS_DIR/*.fastq" | grep "_2" | wc -l) / 4 ))
# Print the number of reads in the forward and reverse files:
echo "$FORWARD reads in the forward read"
echo "$REVERSE reads in the reverse read"

echo "=== Download complete ==="