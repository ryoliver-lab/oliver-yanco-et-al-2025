#!/bin/bash

#SBATCH -t 03:00:00
#SBATCH --job-name part2_step3
#SBATCH -c 3
#SBATCH --mem=200G

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


# ------------ Model reruns for problematic MCMCs - Additive Models ------------

echo "STARTING SCRIPT: refit-space-use-additive-models.r"

Rscript $src_part2/refit-space-use-additive-models.r $wd/out/dbbmm_size.csv $wd/out/single_species_models_reruns/area_additive 1

echo "SCRIPT COMPLETE: refit-space-use-additive-models.r"

# ------------ Model reruns for problematic MCMCs - Interactive Models ------------

echo "STARTING SCRIPT: refit-space-use-interactive-models.r"

Rscript $src_part2/refit-space-use-interactive-models.r $wd/out/dbbmm_size.csv $wd/out/single_species_models_reruns/area_interactive 1

echo "SCRIPT COMPLETE: refit-space-use-interactive-models.r"

# ------------ Model summary for reruns ------------

echo "STARTING SCRIPT: area_model_summaries_reruns.r"

Rscript $src_part2/area_model_summaries_reruns.r

echo "SCRIPT COMPLETE: area_model_summaries_reruns.r"

echo "JOB COMPLETE"
