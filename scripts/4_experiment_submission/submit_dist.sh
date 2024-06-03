#!/bin/bash
#SBATCH --job-name=cford_haddock3_h5_dist
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --constraint=skylake
#SBATCH --mem=300gb
#SBATCH --time=5:00:00

export input_csv=experiments_test.csv
# export input_csv=experiments_full.csv

while IFS="," read -r experiment_id
do
  echo "Submitting HADDOCK 3 Experiment..."
  echo "  Experiment ID: $experiment_id"
  echo "=================================="
  JOBID=$(bash submit_iter.sh $experiment_id)
done < <(tail -n +2 $input_csv)