# Shotgun Metagenomic Preprocessing Pipeline (Parallelized)

This repository contains a pipeline for **preprocessing shotgun metagenomic samples**, from **raw sequencing data to non-normalized abundance tables**.

The workflow is designed to be **parallelized**, allowing multiple samples to be processed simultaneously across multiple steps. Scripts are optimized for execution in HPC environments using SLURM or SGE scheduling systems.

> ⚠️ **Warning**: Shotgun data is large and computationally intensive. Processing many samples at once (e.g., 15 - 25) may cause system overload.
> 
> ⚠️ **Warning 2 **: This pipeline does **not** include instructions or automated scripts for obtaining the human–host and microbiome reference databases. You must download and configure those resources manually before running the workflow.
---

## ⚙️ Structure

- **Parallel execution** – Samples are processed in parallel across all steps to reduce runtime.
- **Modular structure** – Split into five main steps, each handled by a dedicated script:

| script       | Description                                                                                   |
|:----------:|-----------------------------------------------------------------------------------------------|
| `1_human_remove` | Aligns raw reads to the human genome using Bowtie2 (`–very-sensitive-local -k 1`) and extracts non-human reads with Samtools. |
| `2_QC_before`    | Runs initial quality control on raw FASTQ files using FastQC and aggregates reports with MultiQC.                       |
| `3_dedup_trim`   | Removes duplicate reads with Clumpify, performs quality trimming (PHRED > 20) and adapter removal with BBDuk; discards pairs where one read < 75 bp. |
| `4_QC_after`     | Performs post-processing quality control on trimmed reads with FastQC and MultiQC to verify improvements.               |
| `5.1_kraken`     | Classifies clean reads taxonomically using Kraken2 with a 0.1% confidence threshold against the UHGG database.         |
| `5.2_braken`     | Refines Kraken2 species-level abundance estimates using Bracken with a read-length parameter of 150 bp.                |
| `5.3_krakentools2` | Converts Kraken2/Bracken reports into MetaPhlAn-style abundance tables (MPA format) for downstream analysis.          |


Additional files needed:
 | script       | Description                                                                                   |
|:----------:|-----------------------------------------------------------------------------------------------|
| `combine_mpa.py`   | Merges individual MPA abundance tables across all samples into a single consolidated matrix.                 |
| `kreport2mpa.py`   | Parses Kraken2 `.kreport` or Bracken output and converts it into an MPA-compatible format.                   |
| `options.txt`      | Configuration file specifying input/output paths, sample lists, thresholds, and resource parameters for the pipeline. |


- **Intermediate file management** – Temporary files are generated and stored in a structured way to facilitate clean-up.
- **Final outputs** – Include merged abundance tables and QC reports.



## 🧪 Script Header Configuration

Each script is parallelizable via its **SGE/SLURM headers**. These must be modified according to your cluster settings.

**Example (SGE header):**
```bash
#!/bin/bash              # Shell to use
#$ -cwd                  # Run in current working directory
#$ -S /bin/bash          # Command shell
#$ -pe smp 5             # Number of CPUs
#$ -l mf=20G             # Requested memory
#$ -N 1_hr               # Job name
#$ -e log_1_hr           # Error log file
#$ -o log_1_hr           # Output log file
#$ -t 1-46               # Task array: number of samples
#$ -tc 15                # Max simultaneous tasks

🚀 How to Run the Pipeline
Step-by-step:
Copy Required Files to Project Directory:

combine_mpa.py

kreport2mpa.py

parallelized/scripts/

parallelized/options.txt

Configure:

Edit options.txt as needed (input/output paths, parameters).

Modify the header of each script to fit your cluster environment.

Execute Scripts:
Submit each script in sequence via:

bash
Copiar
Editar
qsub 1_human_remove.qsub
qsub 2_QC_before.qsub
qsub 3_dedup_trim.qsub
qsub 4_QC_after.qsub
qsub 5.1_kraken.qsub
qsub 5.2_braken.qsub
qsub 5.3_krakentools2.qsub


