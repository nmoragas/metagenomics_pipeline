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
| `options.txt`      | Configuration file specifying input/output paths, sample number, and kraken database dir. |


- **Intermediate file management** – Temporary files are generated and stored in a structured way to facilitate clean-up.
- **Final outputs** – Include merged abundance tables and QC reports.


## 🚀 How to Run the Pipeline

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


De manera automiatica es cren carpetes on es van guardant els arxius finals i temporal de cadascun dels pasos. amb la seguent estructura

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

├── 5.1_kraken
├── 5.2_braken
└── 5.3_krakentools2



```

