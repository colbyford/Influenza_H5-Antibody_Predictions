#!/bin/bash
#SBATCH --job-name=cford_haddock3_h5_$1
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --constraint=skylake
#SBATCH --mem=300gb
#SBATCH --time=5:00:00
#
# singularity exec haddock.sif python3 inference.py \
#     --complex_path $2 \
#     --complex_name $1 \
#     --out_dir results/user_predictions_small \
#     --inference_steps 20 \
#     --samples_per_complex 40 \
#     --batch_size 10 \
#     --actual_steps 18 \
#     --no_final_step_noise
#
# singularity run $SINGULARITY_CONTAINER_HOME/haddock.sif
#
module load singularity

cd $2
singularity exec haddock3.sif /bin/bash haddock3 config.cfg