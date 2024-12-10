#!/bin/bash
#SBATCH --job-name="af3_H5"
#SBATCH --partition=GPU
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --mem=256GB
#SBATCH --gres=gpu:L40S:2
#SBATCH --time=1:00:00

module load singularity

## AF3 Resources
export AF3_RESOURCES_DIR=/users/cford/alphafold3_resources
export AF3_IMAGE=${AF3_RESOURCES_DIR}/image/alphafold3.sif
export AF3_CODE_DIR=${AF3_RESOURCES_DIR}/code
export AF3_MODEL_PARAMETERS_DIR=${AF3_RESOURCES_DIR}/weights
export AF3_DATABASES_DIR=${AF3_RESOURCES_DIR}/databases

## Experiment Resources
export AF3_EXPERIMENT_DIR=/users/cford38/Influenza_H5-Antibody_Predictions/Q226L_study/data/experiments/alphafold3
export AF3_INPUT_DIR=${AF3_EXPERIMENT_DIR}/${1}
export AF3_OUTPUT_DIR=${AF3_EXPERIMENT_DIR}/${1}

singularity exec \
     --nv \
     --bind $AF3_INPUT_DIR:/root/af_input \
     --bind $AF3_OUTPUT_DIR:/root/af_output \
     --bind $AF3_MODEL_PARAMETERS_DIR:/root/models \
     --bind $AF3_DATABASES_DIR:/root/public_databases \
     $AF3_IMAGE \
     python ${AF3_CODE_DIR}/alphafold3/run_alphafold.py \
     --json_path=/root/af_input/alphafold_input.json \
     --model_dir=/root/models \
     --db_dir=/root/public_databases \
     --output_dir=/root/af_output