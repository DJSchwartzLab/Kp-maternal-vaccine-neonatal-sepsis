#!/bin/bash
#
#================================================================================
# File name    : s06_countreads_postprocessed.sh
# Description  : This script loops through a specified directory and counts reads
#                for all fastq files. The results are written to
#                preprocessed_readcounts.txt in the output directory.
# Usage        : sbatch s06_countreads_postprocessed.sh
# Author       : Jessica Tung
# Version      : 1.0
# Created on   : 04/01/2026
#================================================================================
#
# Submission script for HTCF
#SBATCH --time=0-00:00:00
#SBATCH --job-name=countreads_postprocessed
#SBATCH --mail-user=j.l.tung@wustl.edu
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --output=slurmout/countreads_postprocessed/countreads_postprocessed_%j.out
#SBATCH --error=slurmout/countreads_postprocessed/countreads_postprocessed_%j.err

# Set directories
BASEDIR=/scratch/djslab/jltung/Kp_stools
INDIR=$BASEDIR/bbmap_repaired
OUTDIR=$BASEDIR/countreads_postprocessed
COUNT_FILE=$OUTDIR/postprocessed_readcounts.txt

mkdir -p $OUTDIR

# Write header
echo -e "filename\tread_count" > $COUNT_FILE

for file in $INDIR/*fastq
do
    fname=$(basename "$file")
    reads=$(awk '{s++} END {print s/4}' "$file")
    echo -e "${fname}\t${reads}" >> $COUNT_FILE
done
