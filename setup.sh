#!/bin/bash

# This script sets up the environment for the long-read analysis project.

# This command installs the tools needed for the course in a conda environment called ngs-projects.
conda create -n ngs-projects --override-channels -c conda-forge -c bioconda \
  --strict-channel-priority samtools bowtie2 hisat2 minimap2 fastp fastqc \
  subread freebayes gatk4 nanoplot multiqc "openjdk=17" salmon gffread oarfish \
  entrez-direct sra-tools

# Then activate the conda environment :
conda activate ngs-projects