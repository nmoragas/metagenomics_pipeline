# metagenomics_pipeline
<p align="left">
Shotgun metagenomics pipeline for processing microbiome samples
</p>

---
## Table of contents

- [Overview](#over) - Overview of the project's purpose and goals
- [Respository structure](#rep_stru) - Instructions on how to begin with this project
- [Prerequisites](#prere) - Required software and installation steps 
- [Workflow](#workflow) - Detailed guide to each stage of the project

- [Authors](#authors) - List of contributors to the project
- [Acknowledgments](#acknowledgement) - Credits and thanks to those who helped with the project


## Overview <a name = "over"></a>
The repository presents a comprehensive workflow for metagenomic analysis, starting from an initial assessment of data quality to an 
in-depth understanding of the composition and function of the examined microbiome. The analysis begins with a quality check of the 
sequenced data using FastQC, followed by a specific quality control for metagenomic data with Kneaddata. Subsequently, the workflow 
proceeds to the assembly of the reads with MegaHit and the classification of contigs into eukaryotic or prokaryotic. Anvi'o is then 
employed for the taxonomic and functional annotation of the contigs, as well as for mapping high-quality reads. Finally, Metaphlan 4.0 
facilitates further taxonomic annotation and the estimation of the abundance of various species based on reference genomes, thus 
completing the comprehensive analysis of the microbiome.

## Respository structure <a name = "rep_stru"></a>

The table below provides an overview of the key files and directories in this repository, along with a brief description of each.
|File  |Description            |
|:----:|-----------------------|
|[bin/](bin/)|Folder with python scripts adapted to the workflow|
|[map/](map/)|Folder with pdf and png for better rapresent the workflow|
|[old_scripts](old_scripts)|Folder with all the scripts used for creating the workflow (qc, assemblying, predictions, taxonimical annotation, mapping, etc...|
|[nextflow.config](nextflow.config)|Configuration file which contains a nextflow configuration for running the bioinformatics workflow, including parameters for processing genomic data on Azure cloud service|
|[nextflow_config_full_draft.txt](nextflow_config_full_draft.txt)|Text file which contains a configuration for nextflow workflow specifying resources requirements for each program used|


- `data/`: raw and processed data 
- `scripts/`: all pipeline steps 
- `docs/`: supplementary tables and figures

## Prerequisites <a name = "prere"></a>

## Workflow <a name = "workflow"></a>


## Authors <a name = "authors"></a
Contact me at nmoragas@idibell.cat if you are interested in running it before it is done.
- [nmoragas@idibell.cat](https://github.com/nmoragas)

  
