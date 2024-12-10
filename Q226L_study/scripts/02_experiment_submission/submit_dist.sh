#!/bin/bash

export input_csv=./folding_jobs.csv

while IFS="," read -r experiment_id
do
  echo "Submitting Input: $experiment_id"
  echo ""

  JOBID=$(sbatch submit_iter.sh $experiment_id)
  echo $JOBID

done < <(tail -n +2 $input_csv)