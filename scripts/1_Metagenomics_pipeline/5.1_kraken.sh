#!/bin/bash

#SBATCH --job-name=krak_1
#SBATCH --mem=40G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --output=krak_1.txt
#SBATCH --error=krak_1.txt
#SBATCH --chdir=.
##SBATCH --array=1-2%2


set -e
quality=20



options=options.txt
source $(echo $options)



########################################
#######   5_Kraken + braken       #######
########################################


# Load modules

module load apps/kraken2/2.1.3
module load apps/bracken/2.9

#Classify reads with kraken2


mkdir -p temp/5_kraken

mkdir -p temp/5_kraken/1_kraken2

mkdir -p temp/5_kraken/1_kraken2/k2_outputs
mkdir -p temp/5_kraken/1_kraken2/k2_reports




## 5.1_generacio_list_fw_rv.txt
#################################################################################


for i in temp/3_dedup_trim/seq_output/*m1.fq ; do
  echo "$(realpath "$i")";
 done > temp/5_kraken/1_kraken2/5_list_forward_qc.txt

sleep 10

for i in temp/3_dedup_trim/seq_output/*m2.fq ; do
   echo "$(realpath "$i")";
done > temp/5_kraken/1_kraken2/5_list_reverse_qc.txt


sleep 10


## 5.2_unio_list_fw_rv.txt. 
#################################################################################
## Create a TXT file combining the contents of `list_forward_sf` and `list_reverse` in this directory:

paste -d ' ' temp/5_kraken/1_kraken2/5_list_forward_qc.txt temp/5_kraken/1_kraken2/5_list_reverse_qc.txt > temp/5_kraken/1_kraken2/5_filelist.txt
sleep 30




## 5.1_KRAKEN
##############################################################################


filelist_5=temp/5_kraken/1_kraken2/5_filelist.txt
m5=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $filelist_5 | cut -d ' ' -f1)
m6=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $filelist_5 | cut -d ' ' -f2)

fname=$(echo $m5 | awk -F "/" '{print $NF}' | cut -f1 -d "." | sed 's/R1//')


kraken2 --db ${kraken_database}/ \
  --confidence 0.1 \
  --threads 24 \
  --use-names \
  --output ${out5}/${fname}output.txt \
  --report ${rep5}/${fname}report.txt \
  --paired $m5 $m6



