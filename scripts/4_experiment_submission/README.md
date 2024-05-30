# Submitting HADDOCK 3 Jobs Through Slurm

1. Make a Singularity image from the HADDOCKer image.

```bash
module load singularity

singularity pull haddock3.sif docker://cford38/haddock:3
```

2. Test that HADDOCK 3 runs in Singularity

    - Note: You should ssh into an interactive node: `ssh sth-i3`

```bash
singularity run haddock3.sif /bin/bash

haddock3 config.cfg
```