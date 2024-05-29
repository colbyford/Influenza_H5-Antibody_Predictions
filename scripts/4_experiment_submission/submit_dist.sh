#!/bin/bash
#SBATCH --job-name=cford_haddock3_h5_dist
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --constraint=skylake
#SBATCH --mem=300gb
#SBATCH --time=5:00:00

export SINGULARITY_CONTAINER_HOME=/home/gridsan/$USER/seqer_shared/N_cytokine_docking
export input_csv=../cluster_tests/analyses.csv

# module load singularity
# singularity run $SINGULARITY_CONTAINER_HOME/haddock.sif

while IFS="," read -r complex_id experiment_path n_protein n_pdb n_residues cytokine_protein cytokine_pdb cytokine_residues
do
  echo "Complex ID: $complex_id"
  echo "Experiment Path: $experiment_path"
  echo ""

  # JOBID=$(sbatch --parsable submit_iter.sh $complex_id $experiment_path)
  JOBID=$(bash submit_iter.sh $complex_id $experiment_path)

done < <(tail -n +2 $input_csv)