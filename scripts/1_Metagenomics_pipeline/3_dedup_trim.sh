#!/bin/bash

#SBATCH --job-name=dedup_trim
#SBATCH --mem=40G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --output=dedup_trim.txt
#SBATCH --error=dedup_trim.txt
#SBATCH --chdir=.
##SBATCH --array=1-2%2

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
#####         3_dedup_trim         #####
########################################

mkdir -p temp/3_dedup_trim/seq_dedum_trim
mkdir -p temp/3_dedup_trim/seq_output


## 3.1_generacio_list_fw_rv.txt
#################################################################################

for f in temp/1_human_remove/nohuman/*.fq; do
  if [[ -f "$f" ]]; then
    newname="${f/_1_/_}"
    mv "$f" "$newname"
  fi
done




sleep 20


if [ ! -e "temp/3_dedup_trim/3_list_forward_sg.txt" ]; then
  for i in temp/1_human_remove/nohuman/*m1.* ; do
    echo "$(realpath "$i")";
  done > temp/3_dedup_trim/3_list_forward_qc.txt
fi

sleep 30

if [ ! -e "temp/3_dedup_trim/3_list_reverse_sg.txt" ]; then
  for i in temp/1_human_remove/nohuman/*m2.* ; do
    echo "$(realpath "$i")";
  done > temp/3_dedup_trim/3_list_reverse_qc.txt
fi

sleep 30


## 3.2_unio_list_fw_rv.txt. 
#################################################################################
## Create a txt with the info of list_forward_sf + list_reverse. Dins aquesta mateixa folder:

if [ ! -e "temp/3_dedup_trim/3_filelist.txt" ]; then
  paste -d ' ' temp/3_dedup_trim/3_list_forward_qc.txt temp/3_dedup_trim/3_list_reverse_qc.txt > temp/3_dedup_trim/3_filelist.txt
fi


sleep 50




## 3.3_bbpipeline.qsub
#################################################################################



filelist_2=temp/3_dedup_trim/3_filelist.txt


m3=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $filelist_2 | cut -d ' ' -f1)
m4=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $filelist_2 | cut -d ' ' -f2)
id2=$(echo $m3 | awk -F "/" '{print $NF}' | cut -f1 -d "." | sed 's/R1//')

clumpify.sh \
    Xmx28g \
    in1=$m3 \
    in2=$m4 \
    out1=${temp3}/${id2}_deduped.m1.fq \
    out2=${temp3}/${id2}_deduped.m2.fq \
    dedupe \
    subs=1 \
    k=11 \
    passes=3 \
    &> ${temp3}/${id}_deduplicationstats.txt

bbduk.sh \
    Xmx28g \
    in1=${temp3}/${id2}_deduped.m1.fq \
    in2=${temp3}/${id2}_deduped.m2.fq \
    out1=${out3}/${id2}_Q${quality}.m1.fq \
    out2=${out3}/${id2}_Q${quality}.m2.fq \
    ref=adapters,artifacts,phix \
    k=25 \
    mink=6 \
    hdist=1 \
    hdist2=0 \
    ktrim=r \
    qtrim=rl \
    trimq=$quality \
    minlength=75 \
    stats=${temp3}/${id2}_adapters.txt \
    dump=${temp3}/${id2}_kmers.txt \
    &> ${temp3}/${id2}_cleaning.txt
