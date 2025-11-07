#!/bin/bash
#SBATCH --job-name=hum_rem
#SBATCH --mem=40G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --output=hum_rem.txt
#SBATCH --error=hum_rem.txt
#SBATCH --chdir=.
#SBATCH --array=1-2%2

# Please note that this was done before submission

module load apps/java 
module load apps/bowtie2/2.5.4
module load apps/samtools/1.21
module load apps/bbmap/39.12


set -e
quality=20


options=options.txt
source $(echo $options)


########################################
########    1_human_remove       #######
########################################

mkdir -p temp/1_human_remove


## 1.1_generacio_list_fw_rv.txt
#################################################################################



if [ ! -e "temp/1_human_remove/1_list_forward_sg.txt" ]; then
  for i in ${raw}/*/*_1.* ; do
    # Utiliza 'realpath' para obtener la ruta completa del archivo
    echo "$(realpath "$i")";
  done > temp/1_human_remove/1_list_forward_sg.txt
fi


sleep 30

if [ ! -e "temp/1_human_remove/1_list_reverse_sg.txt" ]; then
  for i in ${raw}/*/*_2.* ; do
    # Utiliza 'realpath' para obtener la ruta completa del archivo
    echo "$(realpath "$i")";
  done > temp/1_human_remove/1_list_reverse_sg.txt
fi


sleep 30


## 1.2_unio_list_fw_rv.txt. 
#################################################################################
## Create a text file in this same directory that combines the contents of list_forward_sf and list_reverse:



paste -d ' ' temp/1_human_remove/1_list_forward_sg.txt temp/1_human_remove/1_list_reverse_sg.txt > temp/1_human_remove/1_filelist.txt

sleep 30


## 1.3_sub_remove_human.txt
#################################################################################



mkdir -p temp/1_human_remove/nohuman
mkdir -p temp/1_human_remove/human



filelist_1=temp/1_human_remove/1_filelist.txt



m1=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $filelist_1 | cut -d ' ' -f1)
m2=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $filelist_1 | cut -d ' ' -f2)
id=$(echo $m1 | awk -F "/" '{print $NF}' | cut -f1 -d "." | sed 's/_R1//')




bowtie2 \
    -x ${human_database} \
    -p 8 \
    -1 ${m1} \
    -2 ${m2} \
    -S ${temp1}/${id}_human.sam \
    --very-sensitive-local \
    -k 1




samtools fastq -@ 8 \
    -1 ${out1}/${id}_nohuman.m1.fq \
    -2 ${out1}/${id}_nohuman.m2.fq \
    -f 12 ${temp1}/${id}_human.sam
