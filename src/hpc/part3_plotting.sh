#!/bin/bash

#SBATCH -t 02:00:00
#SBATCH --job-name part3_main_figs

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

# ------------ Create species list ------------

echo "STARTING SCRIPT: create-species-list.R"

Rscript $src_part3/create-species-list.R

echo "SCRIPT COMPLETE: create-species-list.R"

# ------------ Sum events per hex geometry ------------

# NOTE: This script cannot be run without access to the cleaned database.
#       Since the db cannot made publicly available on Open Science 
#       Framework, this script has been commented out in part3_plotting, but the 
#       output sf object needed to produce figure 1 has been publicly archived.
#       This script cannot be moved to part1 because it requires the output of
#       create_species_list.R which takes inputs from part3_model_effects.sh

# echo "STARTING SCRIPT: events_per_hex.R"

# Rscript $src_part1/events_per_hex.R

# echo "SCRIPT COMPLETE: events_per_hex.R"

# ------------ Fig 1 ------------

echo "STARTING SCRIPT: plot-figure1.R"

Rscript $src_part3/plot-figure1.R

echo "SCRIPT COMPLETE: plot-figure1.R"

# ------------ Fig 2 ------------

echo "STARTING SCRIPT: plot-figure2.R"

Rscript $src_part3/plot-figure2.R

echo "SCRIPT COMPLETE: plot-figure2.R"

# ------------ Fig 3 ------------

echo "STARTING SCRIPT: plot-figure3.R"

Rscript $src_part3/plot-figure3.R

echo "SCRIPT COMPLETE: plot-figure3.R"

# ------------ Fig 4 ------------

echo "STARTING SCRIPT: plot-figure4.R"

Rscript $src_part3/plot-figure4.R

echo "SCRIPT COMPLETE: plot-figure4.R"

# ------------ Fix rate summary ------------

echo "STARTING SCRIPT: fixrate_summary.R"

Rscript $src_part3/fixrate_summary.R

echo "SCRIPT COMPLETE: fixrate_summary.R"

# ------------ CBG area distribution ------------

echo "STARTING SCRIPT: cbg-area-distribution.R"

Rscript $src_part3/cbg-area-distribution.R

echo "SCRIPT COMPLETE: cbg-area-distribution.R"

# ------------ dBBMM area distribution ------------

echo "STARTING SCRIPT: dbbmm-area-distribution.R"

Rscript $src_part3/dbbmm-area-distribution.R

echo "SCRIPT COMPLETE: dbbmm-area-distribution.R"

# ------------ Extended data table 2 ------------

echo "STARTING SCRIPT: extended-data-table2.R"

Rscript $src_part3/extended-data-table2.R

echo "SCRIPT COMPLETE: extended-data-table2.R"

echo "JOB COMPLETE"
