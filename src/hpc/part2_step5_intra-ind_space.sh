#!/bin/bash

#SBATCH -t 48:00:00
#SBATCH --job-name part2_step5
#SBATCH -c 32
#SBATCH --mem=300G


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


# ------------ Area Intra-Individual Interactive Analysis Random Slopes ------------

echo "STARTING SCRIPT: fit_intra_ind_int_mod_random_slopes_space.r"

Rscript $src_part2/fit_intra_ind_int_mod_random_slopes_space.r $wd/out/dbbmm_size.csv $wd/out/intra_ind_models 29 10000 5

echo "SCRIPT COMPLETE: fit_intra_ind_int_mod_random_slopes_space.r"


# ------------ Area Intra-Individual Additive Analysis Random Slopes ------------

echo "STARTING SCRIPT: fit_intra_ind_add_mod_random_slopes_space.r"

Rscript $src_part2/fit_intra_ind_add_mod_random_slopes_space.r $wd/out/dbbmm_size.csv $wd/out/intra_ind_models 29 10000 2

echo "SCRIPT COMPLETE: fit_intra_ind_add_mod_random_slopes_space.r"

echo "JOB COMPLETE"