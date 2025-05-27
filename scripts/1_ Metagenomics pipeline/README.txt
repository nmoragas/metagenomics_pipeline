Shotgun Metagenomic Preprocessing Pipeline (Parallelized)
This repository contains a pipeline for preprocessing shotgun metagenomic samples, from raw sequencing data to non-normalized abundance tables.

The workflow is designed to be parallelized, allowing multiple samples to be processed simultaneously across multiple steps. Scripts are optimized for execution in HPC environments using SLURM or SGE scheduling systems.

⚠️ Warning: Shotgun data is large and computationally intensive. Processing many samples at once (e.g., 15) may cause system overload. Please consult your system administrator before running this pipeline at scale. Last tested on Logos cluster.

⚙️ Features
Parallel execution – Samples are processed in parallel across all steps to reduce runtime.

Modular structure – Split into five main steps, each handled by a dedicated script.

Intermediate file management – Temporary files are generated and stored in a structured way to facilitate clean-up.

Final outputs – Include merged abundance tables and QC reports.

📁 Directory Structure
parallelized/

scripts/
Contains all pipeline scripts:

Copiar
Editar
1_human_remove
2_QC_before
3_dedup_trim
4_QC_after
5_kraken/
  ├── 5.1_kraken
  ├── 5.2_braken
  └── 5.3_krakentools2
options.txt – Configuration file for paths and input/output names.

🧪 Script Header Configuration
Each script is parallelizable via its SGE/SLURM headers. These must be modified according to your cluster settings.

Example (SGE header):

bash
Copiar
Editar
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
...
qsub 5.3_krakentools2.qsub
Wait for each step to finish before starting the next.

Output Folders:

temp/ – Contains intermediate files organized by step (including QC reports).

out/ – Final output (merged abundance tables).

log_* – Log files for debugging and traceability.

Review QC Results.

Clean Up Temporary Files (Optional):

⚠️ This will delete most files in the temp/ folder, keeping only final QC reports:

bash
Copiar
Editar
qsub delete_temp.qsub
📌 Notes
Scripts are intended for experienced users familiar with HPC environments.

Modify memory and CPU settings based on sample size and available resources.

File naming and directory structures must be respected for the pipeline to function correctly.

