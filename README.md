# Large-Scale Computational Modeling of H5 Influenza Variants Against HA1-Neutralizing Antibodies

<h3 align="right">Colby T. Ford, Shirish Yasa, Khaled Obeid, Rafael Jaimes III, Phillip J. Tomezsko, <br>Sayal Guirales-Medrano, Richard Allen White III, and Daniel Janies</h3>

<!--[![Preprint](https://img.shields.io/badge/bioRxiv-10.1101/2024.07.14.603367-bb2635?style=for-the-badge&logo=read.cv)](https://www.biorxiv.org/content/10.1101/2024.07.14.603367)-->

[![Paper](https://img.shields.io/badge/Lancet_eBioMedicine-10.1016/j.ebiom.2025.105632-1e5499?style=for-the-badge&logo=read.cv)](https://www.thelancet.com/journals/ebiom/article/PIIS2352-3964(25)00076-3/fulltext)

<!--![Interface Example](figures/structures/media/UNCC_H5_mediaheader_AVFluIg03__EPI3358339.png)-->

![Interface Example](figures/structures/media/Blender_FLD194__EPI3158642_combined_001.png)


## Media Mentions

- "The Great Cellular Heist" - Inside UNC Charlotte: https://inside.charlotte.edu/featured-stories/the-great-cellular-heist/
- US News: https://www.usnews.com/news/health-news/articles/2025-04-05/experts-warn-bird-flu-could-pose-growing-risk-to-human-health
- Forbes: https://www.forbes.com/sites/innovationrx/2025/04/02/innovationrx-trump-administration-health-agency-layoffs-threaten-biotech-innovation/
- Eureka Alert: https://www.eurekalert.org/news-releases/1077418

## Data

### Outputs:

- Docking metrics, antigen/antibody metadata, and clustering results: [Experiments.xlsx](Experiments.xlsx)
- Docked structures ($n=1,804$): [data/results](data/results)
- Phylogenetic Tree: [tree0.tnt.nex](scripts/7_analyses/phylogenetics/18k_tree/tree0.tnt.nex)

### Inputs:

- Antigens ($n=164$):
    - Input Sequences: [data/sequences](data/sequences)
    - Predicted Structures: [data/structures/antigens/HA1](data/structures/antigens/HA1)
- Antibodies ($n=11$):
    - Structures: [data/structures/antibodies](data/structures/antibodies)


## Workflow

![Workflow](figures/workflow.svg)

### Scripts

0. Sequence Collection: [0_sequence_collection](scripts/0_sequence_collection)
1. Structure Generation with ColabFold: [1_structure_generation](scripts/1_structure_generation)
2. PDB Structure Preparation: [2_structure_prep](scripts/2_structure_prep)
3. HADDOCK3 Experiment Generation: [3_experiment_generation](scripts/3_experiment_generation)
4. HPC Experiment Submission: [4_experiment_submission](scripts/4_experiment_submission)
5. Cleanup: [5_cleanup](scripts/5_cleanup)
6. Metrics Collection: [6_metrics_collection](scripts/6_metrics_collection)
7. Analyses: [7_analyses](scripts/7_analyses)
    - Statistics: [7_analyses/statistics](scripts/7_analyses/statistics)
    - Structure Analyses: [7_analyses/statistics](scripts/7_analyses/structure_analyses)
    - Phylogenetics: [7_analyses/phylogenetics](scripts/7_analyses/phylogenetics)
    - _GIRAF_ Graph Analyses: [scripts/7_analyses/giraf](scripts/7_analyses/giraf)


## Citation

Ford, C. T., Yasa, S., Obeid, K., Jaimes III, R., Tomezsko, P. J., Guirales-Medrano, S., White III, R. A., and Janies, D. (2025). Large-scale computational modelling of H5 influenza variants against HA1-neutralising antibodies. _eBioMedicine_, 114. doi:10.1016/j.ebiom.2025.105632


```bibtex
@article{ford2025,
    author = {Ford, Colby T. and Yasa, Shirish and Obeid, Khaled and Jaimes III, Rafael and Tomezsko, Phillip J. and Guirales-Medrano, Sayal and White III, Richard Allen and Janies, Daniel},
    title = {{Large-Scale Computational Modelling of H5 Influenza Variants Against HA1-Neutralising Antibodies}},
    year = {2025},
    month = {Apr},
    day = {01},
    publisher = {Elsevier},
    volume = {114},
    issn = {2352-3964},
    doi = {10.1016/j.ebiom.2025.105632},
    url = {https://doi.org/10.1016/j.ebiom.2025.105632},
    journal = {Lancet eBioMedicine}
}
```
