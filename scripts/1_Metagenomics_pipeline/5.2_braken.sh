#!/bin/bash

#SBATCH --job-name=krak_2
#SBATCH --mem=40G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --output=krak_2.txt
#SBATCH --error=krak_2.txt
#SBATCH --chdir=.
##SBATCH --array=1-2%2


# Load modules
#module load apps/kraken2-2.0.8-beta
module load apps/kraken2/2.1.3
module load apps/bracken/2.9

set -e
quality=20


options=options.txt
source $(echo $options)


## 5.2_BRAKEN
##############################################################################

mkdir -p temp/5_kraken/2_braken 



# FOR SPECIES:----------------------------------------------------------------

#mkdir temp/5_kraken/2_braken/species 

for i in temp/5_kraken/1_kraken2/k2_reports/*_Q20report.txt
do
  filename=$(basename "$i")
  fname="${filename%.report.txt}"
  bracken -d ${kraken_database} -i $i -r 150 -t 10 -l S -o temp/5_kraken/2_braken/species/${fname}_report_species.txt 
done

mv temp/5_kraken/1_kraken2/k2_reports/*_bracken.txt temp/5_kraken/2_braken/species




########################################
#####        CHECK POINT 8        #####
########################################


n_expected_8=$((n*2))

while true; do
    current_files_8=$(find temp/5_kraken/2_braken/species -maxdepth 1 -type f -name "*.txt" | wc -l)
    [[ $current_files_8 -ge $n_expected_8 ]] && break
    sleep 10  # Espera un segundo antes de revisar nuevamente
done

echo "Check point 8 = archivos esperados ok"


## 5.3_krakentools_1
##############################################################################

## Transformation to mpa format

# SPECIE

mkdir temp/5_kraken/2_braken/species/mpa


for i in temp/5_kraken/2_braken/species/*report_bracken.txt
do
  filename=$(basename "$i")
  fname="${filename%.report_bracken.txt}"
  python ./kreport2mpa.py -r $i -o temp/5_kraken/2_braken/species/mpa/${fname}_mpa.txt --display-header
done














