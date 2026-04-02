#!/bin/bash

#===============================================================================
# File name    : s04_deconseq_multi.sh
# Description  : Run DeconSeq_multi against the human genome.
# Usage        : sbatch s04_deconseq_multi.sh
# Author       : Jessica Tung
# Version      : 1.0
# Created on   : 04/01/2026
#===============================================================================

#SBATCH --job-name=deconseq_multi
#SBATCH --array=1-2
#SBATCH --mem=64G
#SBATCH --time=3-00:00:00 #days-hh:mm:ss
#SBATCH --cpus-per-task=1
#SBATCH --output=slurmout/deconseq_multi/x_deconseq_%a.out
#SBATCH --error=slurmout/deconseq_multi/y_deconseq_%a.err

# Load DeconSeq module
# Loading from Schwartz lab Spack instance the associated DeconSeq configuration file below has been edited to:
# 1.) point to the Dantas Lab ref DB folder: /ref/gdlab/data/deconseq_db,
# 2.) recognize that the DB folder contains database files for the mouse genome and archaeal genomes, and not just the human, bacterial, and viral genomes that are default available databases,
# 3.) point to the correct directory for bwa64 executable.
# /ref/djslab/software/spack-0.18.1/opt/spack/linux-rocky8-x86_64/gcc-8.5.0/deconseq-standalone-0.4.3-ikgqjmgyy4sujmjugkfw7yik4mnrwe6m/De$
# Use command: deconseq.pl -show_dbs to see the available databases (mouse, hsref, arch, bact, vir in the Schwartz lab)

eval "$( spack load --sh deconseq-multi@1.0.0 )"

# Define input and output directories
BASEDIR="/scratch/djslab/jltung/Kp_stools"
INDIR="${BASEDIR}/trimmed"
OUTDIR="${BASEDIR}/deconseq_out"

# Create output directory if it doesn't exist
mkdir -p ${OUTDIR}

# Samples for slurm array
ID=`sed -n ${SLURM_ARRAY_TASK_ID}p ${BASEDIR}/mappingfile.txt`

# Run deconseq on forward paired reads, filtering out human genome
deconseq.pl \
-f ${INDIR}/${ID}_CLEAN_FW.fastq \
-out_dir ${OUTDIR} \
-id ${ID}_FW \
-dbs mouse \
-t 16

# Run deconseq on reverse paired reads, filtering out human genome
deconseq.pl \
-f ${INDIR}/${ID}_CLEAN_RV.fastq \
-out_dir ${OUTDIR} \
-id ${ID}_RV \
-dbs mouse \
-t 16

# Print
echo $ID completed
