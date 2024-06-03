#!/bin/bash
#SBATCH --job-name=cford_haddock3_h5_$1
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --constraint=skylake
#SBATCH --mem=300gb
#SBATCH --time=5:00:00

module load singularity
export SINGULARITY_CONTAINER_HOME=$(pwd)

cd ../../data/experiments/$1
singularity exec $SINGULARITY_CONTAINER_HOME/haddock3.sif "haddock3 config.cfg"