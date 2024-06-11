#!/bin/bash
##SBATCH --job-name=cford_haddock3_h5_dist
##SBATCH --partition=Nebula
##SBATCH --nodes=1
##SBATCH --ntasks-per-node=36
##SBATCH --constraint=skylake
##SBATCH --mem=300gb
##SBATCH --time=5:00:00

# export input_csv=experiments_test.csv
# export input_csv=experiments_full.csv
# export input_csv=experiments_part_0.csv
export input_csv=experiments_part_1.csv

echo "Submitting HADDOCK 3 Experiments..."
echo "==================================="
while IFS="," read -r experiment_id
do
  echo "  Experiment ID: $experiment_id"
  echo "==================================="
  JOBID=$(sbatch --parsable submit_iter.sh $experiment_id)
done < <(tail -n +2 $input_csv)