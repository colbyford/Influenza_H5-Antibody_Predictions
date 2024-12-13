#!/bin/bash
#SBATCH --job-name="afrun2"
#SBATCH --partition=GPU
#SBATCH --gres=gpu:1
#SBATCH --constraint=FP32
#SBATCH --time=10-24:01:00
#SBATCH --mem=100G
module load singularity
module load cuda
  
singularity run --nv \
  -B /users/syasa/Flu/alphafold_weights:/cache -B $(pwd):/work \
  ../Flu2/colabfold_1.5.5-cuda11.8.0.sif \
  colabfold_batch --amber --num-relax 1 --use-gpu-relax 5DUP.fasta folded

