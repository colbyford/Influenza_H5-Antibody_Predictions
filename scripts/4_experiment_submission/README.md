# Submitting HADDOCK 3 Jobs Through Slurm

## Prepare Singularity Image and Test

1. Make a Singularity image from the HADDOCKer image.

```bash
module load singularity

singularity pull haddock3.sif docker://cford38/haddock:3
```

2. Running Numerous Experiments

The `submit_dist.sh` script reads in a .csv file that lists the desired experiment IDs to be run. Then, it loops through each ID and spins off jobs for each experiment using the `submit_iter.sh` script. This uses the pulled HADDOCK 3 Docker container that has been converted to a Singularity image.

```bash
bash submit_dist.sh
```


## Testing in Docker

```bash
## Pull the image and retag it
docker pull cford38/haddock:3.0.0-beta.5
docker image tag cford38/haddock:3.0.0-beta.5 haddock3

## Run the container
docker run -v .:/data --name haddock3 -it haddock3 /bin/bash

## Once inside the container
cd /data/data/experiments/<YOUR EXPERIMENT>
haddock3 config.cfg
```

## Testing in Singularity

 - Note: You should ssh into an interactive node: `ssh sth-i3`

```bash
singularity run haddock3.sif /bin/bash

haddock3 config.cfg
```