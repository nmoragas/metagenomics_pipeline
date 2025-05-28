# Shotgun Metagenomic Preprocessing Pipeline (Parallelized)

This repository contains a pipeline for **preprocessing shotgun metagenomic samples**, from **raw sequencing data to non-normalized abundance tables**.

This pipeline is organized into two main parts:

🔹 Part 1: Preprocessing and Taxonomic Classification
Includes initial read processing (filtering, deduplication, trimming), quality control (pre and post), and taxonomic classification using Kraken2/Bracken.

🔹 Part 2: Downstream Statistical Processing
Covers batch effect correction, normalization, and transformation of taxonomic data for robust and interpretable statistical analysis.

The workflow of part 1 is designed to be **parallelized**, allowing multiple samples to be processed simultaneously across multiple steps. Scripts are optimized for execution in HPC environments using SLURM or SGE scheduling systems.

> ⚠️ **Warning**: Shotgun data is large and computationally intensive. Processing many samples at once (e.g., 15 - 25) may cause system overload.
> 
> ⚠️ **Warning 2 **: This pipeline does **not** include instructions or automated scripts for obtaining the human–host and microbiome reference databases. You must download and configure those resources manually before running the workflow.
---

## ⚙️ Structure

- **Parallel execution** – Samples are processed in parallel across all steps to reduce runtime.
- **Modular structure** – Split into five main steps, each handled by a dedicated script:

### 🔹 Part 1: Preprocessing and Taxonomic Classification

Part implemented in a Bash environment

| script       | Description                                                                                   |
|:----------:|-----------------------------------------------------------------------------------------------|
| `1_human_remove.sh` | Aligns raw reads to the human genome using Bowtie2 (`–very-sensitive-local -k 1`) and extracts non-human reads with Samtools. |
| `2_QC_before.sh`    | Runs initial quality control on raw FASTQ files using FastQC and aggregates reports with MultiQC.                       |
| `3_dedup_trim.sh`   | Removes duplicate reads with Clumpify, performs quality trimming (PHRED > 20) and adapter removal with BBDuk; discards pairs where one read < 75 bp. |
| `4_QC_after.sh`     | Performs post-processing quality control on trimmed reads with FastQC and MultiQC to verify improvements.               |
| `5.1_kraken.sh`     | Classifies clean reads taxonomically using Kraken2 with a 0.1% confidence threshold against the UHGG database.         |
| `5.2_braken.sh`     | Refines Kraken2 species-level abundance estimates using Bracken with a read-length parameter of 150 bp.                |
| `5.3_krakentools2.sh` | Converts Kraken2/Bracken reports into MetaPhlAn-style abundance tables (MPA format) for downstream analysis.          |


Additional files needed:
 | script       | Description                                                                                   |
|:----------:|-----------------------------------------------------------------------------------------------|
| `combine_mpa.py`   | Merges individual MPA abundance tables across all samples into a single consolidated matrix.                 |
| `kreport2mpa.py`   | Parses Kraken2 `.kreport` or Bracken output and converts it into an MPA-compatible format.                   |
| `options.txt`      | Configuration file specifying input/output paths, sample number, and kraken database dir. |


- **Intermediate file management** – Temporary files are generated and stored in a structured way to facilitate clean-up.
- **Final outputs** – Include merged abundance tables and QC reports.

### 🔹 Part 2: Downstream Statistical Processing

Part implemented in a R environment

| script       | Description                                                                                   |
|:----------:|-----------------------------------------------------------------------------------------------|
| `6_batch_correction.rmd`   | (optional) Performs batch effect correction on taxonomic profiles using the ConQuR package to reduce technical variability across sample groups. |
| `7_taxonomic_data_preparation.rmd` | Prepares taxonomic abundance data for statistical analysis: includes genome length normalization, zero replacement (zCompositions), compositional data handling, and centered log-ratio (CLR) transformation. |
| `8_phyloseq_object_creation.rmd` | (optional) Builds a `phyloseq` object from processed taxonomic abundance data, taxonomy assignments, and sample metadata, enabling structured and reproducible downstream ecological and statistical analysis.  |


## 🚀 How to Run the Pipeline


### 🔹 Part1:
Step-by-step:

1 Copy Required Files to Project Directory:
 - scripts/
 - combine_mpa.py
 - kreport2mpa.py
 - options.txt

2 Configure:
   a Edit options.txt as needed (input/output paths, parameters).
   b Modify the header of each script to fit your cluster environment. Each script is parallelizable via its **SGE/SLURM headers**. These must be modified according to your cluster settings.
   
   **Example (SLUM header):**
      
```bash
#!/bin/bash
#SBATCH --job-name=job_name        # Name of the job, used in queue listings
#SBATCH --mem=40G                  # Total memory allocation for the job (40 gigabytes)
#SBATCH --ntasks=1                 # Number of tasks (MPI ranks); here a single task
#SBATCH --cpus-per-task=8          # Number of CPU cores allocated to this task
#SBATCH --output=job_name.txt       # File to which STDOUT will be written
#SBATCH --error=job_name.txt        # File to which STDERR will be written
#SBATCH --chdir=.                  # Run the job from the current working directory
# SBATCH --array=1-1300%25         # Submit a task array of 1–1300, with max 25 concurrent
```

3 Execute Scripts:
  Submit each step one at a time, waiting for each job to finish before launching the next:

```bash
sbatch 1_human_remove.qsub
sbatch 2_QC_before.qsub
sbatch 3_dedup_trim.qsub
sbatch 4_QC_after.qsub
sbatch 5.1_kraken.qsub
sbatch 5.2_braken.qsub
sbatch 5.3_krakentools2.qsub
```

Folders are automatically created to store both final and temporary files for each step, following the structure below:

```
temp/
└──── 1_human_remove
       └─── nohuman
       └─── human     
└──── 2_QC_before
└──── 3_dedup_trim
       └─── seq_dedum_trim
       └─── seq_output  
└──── 4_QC_after
└──── 5_kraken/
       └─── 1_kraken
            └─── k2_outputs
            └─── k2_reports
       └─── 2_braken
           └─── species
                └─── mpa
out/
```

The primary input file for downstream analyses is:
`out/bracken_abundance_species_mpa.txt`

### 🔹 Part2:
This stage is carried out in an R environment. It takes as input the file `out/bracken_abundance_species_mpa.txt`, and runs a set of R scripts to perform taxonomic data preparation for statistical analysis.
The batch effect correction step is optional and can be applied depending on the characteristics of the dataset and the study design.

This part of the analysis is implemented in R and is applied to the file out/bracken_abundance_species_mpa.txt, which contains species-level abundance profiles from Bracken.

- `6_batch_correction.rmd`
           Preliminary Checks and Cleaning
  
           a) Clean the abundance table: remove zero-abundance taxa and standardize column names.
           b) Optional Batch Effect Correction. If necessary, batch effect correction is performed at this stage using the ConQuR package.

- `7_taxonomic_data_preparation.rmd`
  
           a) If batch effect correction is not applied: clean the abundance table by removing zero-abundance taxa and standardizing column names.
           b) Normalize species-level abundances by genome length to obtain comparable abundance measures across taxa.

- `8_phyloseq_object_creation.rmd`
  
           A phyloseq object is constructed to facilitate downstream ecological and statistical analysis. It should minimally include:


