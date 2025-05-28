#!/bin/bash

#SBATCH --job-name=krak_3
#SBATCH --mem=40G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --output=krak_3.txt
#SBATCH --error=krak_3.txt
#SBATCH --chdir=.
##SBATCH --array=1-2%2

# Load modules

module load apps/kraken2/2.1.3
module load apps/bracken/2.9
set -e
quality=20



options=options.txt
source $(echo $options)


## 5.4_krakentools_2 - species
##############################################################################

## Merge all files from each sample into one

mkdir -p out


# SPECIE

python ./combine_mpa.py -i */temp/5_kraken/2_braken/species/mpa/*_mpa.txt -o out/combined_species_mpa.txt
grep -E "(s__)|(#Classification)" out/combined_species_mpa.txt > out/bracken_abundance_species_mpa.txt










