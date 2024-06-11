#!/bin/bash
#SBATCH --job-name="hdk3_h5_fab"
##SBATCH --partition=Pisces
#SBATCH --partition=Draco
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --mem=32gb
#SBATCH --time=1:00:00

module load singularity
export SINGULARITY_CONTAINER_HOME=$(pwd)

# cd ../../data/experiments/$1
cd /scratch/cford38/Influenza_H5-Antibody_Predictions/experiments/$1
singularity exec $SINGULARITY_CONTAINER_HOME/haddock3.sif haddock3 config.cfg