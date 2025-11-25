#!/bin/bash

#SBATCH --job-name=pre_qc
#SBATCH --mem=40G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --output=pre_qc.txt
#SBATCH --error=pre_qc.txt
#SBATCH --chdir=.
#SBATCH --array=1-2%2


options=options.txt
source $(echo $options)


########################################
#####   2_QC_FASTQC_before_trim    #####
########################################
set -e
quality=20


mkdir -p temp/2_QC_before_trim


## 2.1_obtaining_fastqchtml
#################################################################################
## Load modules

module load apps/fastqc/0.12.1

fastqc -t 24 temp/1_human_remove/nohuman/* --outdir temp/2_QC_before_trim/

sleep 10

########################################
#####        CHECK POINT 2         #####
########################################


#n=$(wc -l < temp/1_human_remove/1_filelist.txt)
n_expected_2=$((n * 2))

echo "Expected number of temporary files: $n_expected"

while true; do
    current_files=$(find temp/2_QC_before_trim -maxdepth 1 -type f -name "*_fastqc.html" | wc -l)
    [[ $current_files -ge $n_expected_2 ]] && break
    echo "Check point 2 = archivos esperados no ok"
    sleep 10  
done

echo "Check point 2 = archivos esperados ok"




## 2.2_MultiQC_aplication
#################################################################################

## Join all the generated reports for 1_obtaining_fastqchtml.R amb MultiQC

## Load the multiqc module
module load apps/multiqc/1.25.1

#Generate the report
multiqc temp/2_QC_before_trim --outdir temp/2_QC_before_trim 


module unload apps/multiqc/1.25.1        



