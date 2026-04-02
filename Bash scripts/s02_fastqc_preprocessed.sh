#!/bin/bash
#
#================================================================================
# File name    : s02_fastqc_preprocessed.sh
# Description  : This script runs FastQC on paired-end reads.
# Usage        : sbatch s02_fastqc_preprocessed.sh
# Author       : Jessica Tung
# Version      : 1.0
# Created on   : 04/01/2026
#================================================================================
#
# Submission script for HTCF
#SBATCH --time=0-03:00:00 # days-hh:mm:ss
#SBATCH --job-name=fastqc_preprocessed
#SBATCH --mail-user=j.l.tung@wustl.edu
#SBATCH --array=1-2
#SBATCH --mem=8G
#SBATCH --output=slurmout/fastqc_preprocessed/fastqc_%A_%a.out
#SBATCH --error=slurmout/fastqc_preprocessed/fastqc_%A_%a.err

# Load FastQC
eval $(spack load --sh fastqc@0.12.1)

# Define input and output directories
BASEDIR="/scratch/djslab/jltung/Kp_stools"
INDIR="${BASEDIR}/preprocessed_reads"
OUTDIR="${BASEDIR}/fastqc_preprocessed"

mkdir -p ${OUTDIR}

# Get SAMPLE_ID from mapping file
SAMPLE_ID=`sed -n ${SLURM_ARRAY_TASK_ID}p ${BASEDIR}/mappingfile.txt`

# Run FastQC
set -x
time fastqc ${INDIR}/${SAMPLE_ID}_FW.fastq ${INDIR}/${SAMPLE_ID}_RV.fastq -o ${OUTDIR}
RC=$?
set +x

if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error Occured in ${SAMPLE_ID}!"
  exit $RC
fi