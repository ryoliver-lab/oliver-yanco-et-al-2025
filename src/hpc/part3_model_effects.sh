#!/bin/bash

#SBATCH -t 00:30:00
#SBATCH --job-name part3_model_effects

# set up paths for wd, src, R version, and conda env
source src/config1.env
cd $wd

module load $r_version

conda activate $conda_env_name

# define paths for library and compiler
source src/config2.env

# add logging to ensure the new shell is using the intended software
echo "GDAL version:"
gdal-config --version
echo "PROJ version:"
proj
echo "C++ compiler version:"
$CXX --version
echo "Make version:"
make --version


# ------------ Space Use Model Effects ------------

echo "STARTING SCRIPT: select_space_use_model-effects.r" 

Rscript $src_part3/select_space_use_model-effects.r $wd/out/single_species_models $wd/out/covid_results $wd/raw_data/anthropause_data_sheet.csv

echo "SCRIPT COMPLETE: select_space_use_model-effects.r"


# ------------ Area Effects ------------

echo "STARTING SCRIPT: estimate_area_effects.r" 

Rscript $src_part3/estimate_area_effects.r $wd/out/single_species_models $wd/out/covid_results

echo "SCRIPT COMPLETE: estimate_area_effects.r"


# ------------ Niche Model Effects ------------

echo "STARTING SCRIPT: select_niche_model_effects.r" 

Rscript $src_part3/select_niche_model-effects.r $wd/out/single_species_models $wd/out/covid_results $wd/raw_data/anthropause_data_sheet.csv

echo "SCRIPT COMPLETE: select_niche_model_effects.r"


# ------------ Niche Effects ------------

echo "STARTING SCRIPT: estimate_niche_effects.r" 

Rscript $src_part3/estimate_niche_effects.r $wd/out/single_species_models $wd/out/covid_results

echo "SCRIPT COMPLETE: estimate_niche_effects.r"
