#!/bin/bash
#
#================================================================================
# File name    : s03_trimmomatic.sh
# Description  : Trims adapter sequences and low-quality bases from Illumina
#                reads, producing a "cleaned" set of paired reads.
# Usage        : sbatch s03_trimmomatic.sh
# Author       : Jessica Tung
# Version      : 1.0
# Created on   : 04/01/2026
#================================================================================
#
# Submission script for HTCF
#SBATCH --job-name=trimmomatic
#SBATCH --array=1,2
#SBATCH --mem=1G
#SBATCH --output=slurmout/trimmomatic/x_trim_%A_%a.out
#SBATCH --error=slurmout/trimmomatic/y_trim_%A_%a.err

# Load Trimmomatic
eval $( spack load --sh trimmomatic@0.39)

# Define and make directories
BASEDIR="/scratch/djslab/jltung/Kp_stools"
INDIR="${BASEDIR}/preprocessed_reads"
OUTDIR="${BASEDIR}/trimmed"

mkdir -p ${OUTDIR}

# Need to declare memory explicitly
export JAVA_ARGS="-Xmx1000M"

# Choose which adapters to reference:
  ## NexteraPE-PE.fa,
  ## TruSeq2-PE.fa, TruSeq2-SE.fa,
  ## TruSeq3-PE-2.fa, TruSeq3-PE.fa, TruSeq3-SE.fa
adapt="/ref/djslab/data/trimmomatic_adapters/0.39/NexteraPE-PE.fa"

# Get SAMPLE_ID from mapping file
SAMPLE_ID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" \
           "${BASEDIR}/mappingfile.txt")
# R1 = FW and R2 = RV
# P = paired, UP = unpaired

set -x
time trimmomatic \
PE \
-phred33 \
-trimlog \
${OUTDIR}/Paired_${SAMPLE_ID}_trimlog.txt \
${INDIR}/${SAMPLE_ID}_FW.fastq \
${INDIR}/${SAMPLE_ID}_RV.fastq \
${OUTDIR}/${SAMPLE_ID}_CLEAN_FW.fastq \
${OUTDIR}/${SAMPLE_ID}_CLEAN_UP_FW.fastq \
${OUTDIR}/${SAMPLE_ID}_CLEAN_RV.fastq \
${OUTDIR}/${SAMPLE_ID}_CLEAN_UP_RV.fastq \
ILLUMINACLIP:${adapt}:2:30:8:1:true \
SLIDINGWINDOW:4:15 \
LEADING:10 \
TRAILING:10 \
MINLEN:60
RC=$?
set +x

if [ $RC -eq 0 ]; then
    echo "Trimmomatic finished successfully for ${SAMPLE_ID}"
else
    echo "Error occurred in ${SAMPLE_ID}!"
    exit $RC
fi

