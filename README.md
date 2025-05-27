# metagenomics_pipeline
<p align="left">
Shotgun metagenomics pipeline for processing microbiome samples
</p>

---
## Table of contents

- [0 - Overview](#over) - Overview of the project's purpose and goals
- [1 - Respository structure](#rep_stru) - Instructions on how to begin with this project
- [2 - Prerequisites](#prere) - Required software and installation steps 
- [3 - Workflow](#workflow) - Detailed guide to each stage of the project
- [4 - Authors](#authors) - List of contributors to the project


## 0 - Overview <a name = "over"></a>

This repository provides a generalized bioinformatics pipeline for processing,
analyzing, and visualizing shotgun metagenomic data. The workflow includes
standard preprocessing steps such as host (e.g., human) read removal, quality
control, deduplication, trimming, and adapter removal.

Downstream analyses cover taxonomic profiling with tools like Kraken2 and
Bracken2, batch effect correction, and statistical evaluation of microbial
community composition.

The pipeline also supports compositional data analysis, alpha and beta diversity
metrics, differential abundance testing using ANCOM-BC and LINDA, and functional
microbiome profiling with HUMAnN3.

While specific parameters and datasets may differ across projects, the overall
structure follows best practices commonly adopted in microbiome research.


## 1 - Respository structure <a name = "rep_stru"></a>

The table below summarizes the main files and directories in this repository, along with a brief description of their contents.
|File  |Description            |
|:----:|-----------------------|
|[data/](data/)|raw and processed data|
|[scripts/](scripts/)|Folder containing all scripts used to build the workflow.|
|[docs/](docs/)|This folder includes PDF and PNG files that help illustrate the workflow, along with example tables and resulting plots.|

- `data/`: raw and processed data 
- `scripts/`: all pipeline steps 
- `docs/`: supplementary tables and figures

## 2 - Prerequisites <a name = "prere"></a>

## 3 - Workflow <a name = "workflow"></a>


## 4 - Authors <a name = "authors"></a>
Contact me at nmoragas@idibell.cat if you are interested in running it before it is done.
- [nmoragas@idibell.cat](https://github.com/nmoragas)

  
