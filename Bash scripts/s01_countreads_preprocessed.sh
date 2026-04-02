#!/bin/bash
#
#================================================================================
# File name    : s01_countreads_preprocessed.sh
# Description  : This script loops through a specified directory and counts reads
#                for all fastq files. The results are written to
#                preprocessed_readcounts.txt in the output directory.
# Usage        : sbatch s01_countreads_preprocessed.sh
# Author       : Jessica Tung
# Version      : 1.0
# Created on   : 04/01/2026
#================================================================================
#
# Submission script for HTCF
#SBATCH --time=0-00:00:00
#SBATCH --job-name=countreads_preprocessed
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --output=slurmout/countreads_preprocessed/countreads_preprocessed_%j.out
#SBATCH --error=slurmout/countreads_preprocessed/countreads_preprocessed_%j.err

# Set directories
BASEDIR=/scratch/djslab/jltung/Kp_stools
INDIR=$BASEDIR/preprocessed_reads
OUTDIR=$BASEDIR/countreads_preprocessed
COUNT_FILE=$OUTDIR/preprocessed_readcounts.txt

mkdir -p $OUTDIR

# Write header
echo -e "filename\tread_count" > $COUNT_FILE

for file in $INDIR/*fastq
do
    fname=$(basename "$file")
    reads=$(awk '{s++} END {print s/4}' "$file")
    echo -e "${fname}\t${reads}" >> $COUNT_FILE
done
