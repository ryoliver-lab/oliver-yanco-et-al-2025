#!/bin/bash

#SBATCH -t 48:00:00
#SBATCH --job-name part2_step1
#SBATCH -c 32
#SBATCH --mem=300G 

# set up paths for wd, src, R version, and conda env
source config1.env
cd $wd

module load $r_version

conda activate $conda_env_name

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


# ------------ Inferential Models - Fit space use models part 2 ------------

echo "STARTING SCRIPT: fit-space-use-interactive-models.r"

Rscript $src_part2/fit-space-use-interactive-models.r $wd/out/dbbmm_size.csv $wd/out/single_species_models/area_interactive 1 3 10000 5

echo "SCRIPT COMPLETE: fit-space-use-interactive-models.r"


# ------------ Inferential Models - Fit space use models part 3 ------------

echo "STARTING SCRIPT: fit-space-use-additive-models.r"

Rscript $src_part2/fit-space-use-additive-models.r $wd/out/dbbmm_size.csv $wd/out/single_species_models/area_additive 1 3 10000 5

echo "SCRIPT COMPLETE: fit-space-use-additive-models.r"


# ------------ Visualize model outputs from space use models ------------

echo "STARTING SCRIPT: area_model_summaries.r"

Rscript $src_part2/area_model_summaries.r

echo "SCRIPT COMPLETE: area_model_summaries.r."

echo "JOB COMPLETE"