#!/bin/bash
#
#================================================================================
# File name    : s08_metaphlan4.sh
# Description  : Profiles taxonomic composition of a read set using MetaPhlAn 4.
# Usage        : sbatch s08_metaphlan4.sh
# Author       : Jessica Tung
# Version      : 1.0
# Created on   : 04/01/2026
#================================================================================
#
# Submission script for HTCF
#SBATCH --job-name=metaphlan4
#SBATCH --array=1-2
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --output=slurmout/metaphlan4/x_metaphlan4_%A_%a.out
#SBATCH --error=slurmout/metaphlan4/y_metaphlan4_%A_%a.err

# Note: Multiple versions of MetaPhlAn are installed — run `spack find py-metaphlan` to list them.
eval $( spack load --sh miniconda3@4.10.3 )
source activate metaphlan4.2.4

# Define directories
BASEDIR="/scratch/djslab/jltung/Kp_stools"
INDIR="${BASEDIR}/bbmap_repaired"
OUTDIR="${BASEDIR}/metaphlan4"

# Create output directory if it doesn't exist
mkdir -p ${OUTDIR}

# Get SAMPLE_ID from mapping file
SAMPLE_ID=`sed -n ${SLURM_ARRAY_TASK_ID}p ${BASEDIR}/mappingfile.txt`

# Run MetaPhlAn 4
set -x
time metaphlan \
  ${INDIR}/${SAMPLE_ID}_CLEAN_REPAIRED_FW.fastq,${INDIR}/${SAMPLE_ID}_CLEAN_REPAIRED_RV.fastq \
  --input_type fastq \
  --skip_unclassified_estimation \
  --db_dir /ref/djslab/data/metaphlanDB_vJan25_202503 \
  --mapout ${OUTDIR}/${SAMPLE_ID}.bowtie2.bz2 \
  -o ${OUTDIR}/${SAMPLE_ID}_profile.txt \
  --nproc ${SLURM_CPUS_PER_TASK} \
  --index mpa_vJan25_CHOCOPhlAnSGB_202503 \

RC=$?
set +x

# Check for success
if [ $RC -eq 0 ]
then
  echo "Job completed successfully for ${SAMPLE_ID}"
else
  echo "Error occurred in ${SAMPLE_ID}!"
  exit $RC
fi
