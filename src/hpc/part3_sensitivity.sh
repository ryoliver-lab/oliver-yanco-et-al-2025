#!/bin/bash

#SBATCH -t 02:00:00
#SBATCH --job-name part3_sensitivity

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

# ------------ Graph Niche breadth subsamples ------------

echo "STARTING SCRIPT: graph_niche_subsample.R"

Rscript $src/graph_niche_subsample.R

echo "SCRIPT COMPLETE: graph_niche_subsample.R"

# ------------ Plot area size sample balance ------------

echo "STARTING SCRIPT: check_area_size_sample_balance.R"

Rscript $src/check_area_size_sample_balance.R

echo "SCRIPT COMPLETE: check_area_size_sample_balance.R"

# ------------ Check for autocorrelation within intra-individual models ------------

echo "STARTING SCRIPT: check_intra_ind_mod_ac.R"

Rscript $src/check_intra_ind_mod_ac.R

echo "SCRIPT COMPLETE: check_intra_ind_mod_ac.R"

echo "JOB COMPLETE"