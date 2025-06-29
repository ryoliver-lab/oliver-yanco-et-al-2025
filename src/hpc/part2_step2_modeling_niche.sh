#!/bin/bash

#SBATCH -t 24:00:00
#SBATCH --job-name part2_step2
#SBATCH -c 22
#SBATCH --mem=300G 

# set up paths for wd, src, R version, and conda env
source src/config1.env
cd $wd

module load $r_version

conda activate $conda_env_name

# define paths for library and compiler
source src/config2.env

# define paths for library and compiler
source config2.env
# add logging to ensure the new shell is using the intended software
echo "GDAL version:"
gdal-config --version
echo "PROJ version:"
proj
echo "C++ compiler version:"
$CXX --version
echo "Make version:"
make --version


# ------------ Fit niche breadth models part 2 ------------

echo "STARTING SCRIPT: fit-niche-breadth-additive-models.r"

Rscript $src_part2/fit-niche-breadth-additive-models.r $wd/out/MVNH_size.csv $wd/out/dbbmm_size.csv $wd/out/single_species_models/niche_additive 18 3 10000 5

echo "SCRIPT COMPLETE: fit-niche-breadth-additive-models.r"


# ------------ Fit niche breadth models part 3 ------------

echo "STARTING SCRIPT: fit-niche-breadth-interactive-models.r"

Rscript $src_part2/fit-niche-breadth-interactive-models.r $wd/out/MVNH_size.csv $wd/out/dbbmm_size.csv $wd/out/single_species_models/niche_interactive 18 3 10000 5

echo "SCRIPT COMPLETE: fit-niche-breadth-interactive-models.r"

# ------------ Visualize model outputs from niche breadth models ------------

# NOTE: This script cannot be run without access to the cleaned database.
#       Since the db cannot made publicly available on Open Science 
#       Framework, this script has been commented out in part2_modeling, but the 
#       output PDFs have been publicly archived (see model_diagnostics/niche)
#       and the script itself is available.

#echo "STARTING SCRIPT: niche_model_summaries.r"

#Rscript $src_part2/niche_model_summaries.r

#echo "SCRIPT COMPLETE: niche_model_summaries.r"

echo "JOB COMPLETE"