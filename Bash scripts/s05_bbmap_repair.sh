#!/bin/bash
#
#================================================================================
# File name    : s05_bbmap_repair.sh
# Description  : This script will fix paired ends in parallel using repair.sh
#                from BBMap. For use after Trimmomatic & Deconseq. MetaPhlAn
#                does not use paired read info (just all reads concatenated),
#                but if other analyses will be done, it may be necessary to re-pair
#                paired reads. Good practice to always run.
# Usage        : sbatch s05_bbmap_repair.sh
# Author       : Jessica Tung
# Version      : 1.0
# Created on   : 04/01/2026
#================================================================================
#
# Submission script for HTCF
#SBATCH --job-name=bbmap_repair
#SBATCH --array=1-2
#SBATCH --time=6-00:00:00 # days-hh:mm:ss
#SBATCH --mem=16G
#SBATCH --output=slurmout/bbmap_repair/x_bbmap_repair_%a.out
#SBATCH --error=slurmout/bbmap_repair/y_bbmap_repair_%a.err

# Load BBmap module
eval $(spack load --sh bbmap@39.01)

# Define input and output directories
BASEDIR="/scratch/djslab/jltung/Kp_stools"
INDIR="${BASEDIR}/deconseq_out"
OUTDIR="${BASEDIR}/bbmap_repaired"
OUTDIR2="${BASEDIR}/bbmap_repaired_singletons"

# Get SAMPLE_ID from mapping file
SAMPLE_ID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" \
           "${BASEDIR}/mappingfile.txt")

# Run repair
repair.sh --tossbrokenreads \
    in1=${INDIR}/${SAMPLE_ID}_FW_clean.fq \
    in2=${INDIR}/${SAMPLE_ID}_RV_clean.fq \
    out1=${OUTDIR}/${SAMPLE_ID}_CLEAN_REPAIRED_FW.fastq \
    out2=${OUTDIR}/${SAMPLE_ID}_CLEAN_REPAIRED_RV.fastq \
    outs=${OUTDIR2}/${SAMPLE_ID}_CLEAN_REPAIRED_SINGLETONS.fastq.gz
