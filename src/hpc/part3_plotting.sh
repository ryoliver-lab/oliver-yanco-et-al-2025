#!/bin/bash

#SBATCH -t 02:00:00
#SBATCH --job-name part3_main_figs

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

# ------------ Create species list ------------

echo "STARTING SCRIPT: create_species_lisr.R"

Rscript $src/create_species_lisr.R

echo "SCRIPT COMPLETE: create_species_lisr.R"

# ------------ Fig 1 ------------

echo "STARTING SCRIPT: plot-figure1.R"

Rscript $src/plot-figure1.R

echo "SCRIPT COMPLETE: plot-figure1.R"

# ------------ Fig 2 ------------

echo "STARTING SCRIPT: plot-figure2.R"

Rscript $src/plot-figure2.R

echo "SCRIPT COMPLETE: plot-figure2.R"

# ------------ Fig 3 ------------

echo "STARTING SCRIPT: plot-figure3.R"

Rscript $src/plot-figure3.R

echo "SCRIPT COMPLETE: plot-figure3.R"

# ------------ Fig 4 ------------

echo "STARTING SCRIPT: plot-figure4.R"

Rscript $src/plot-figure4.R

echo "SCRIPT COMPLETE: plot-figure4.R"

# ------------ Fix rate summary ------------

echo "STARTING SCRIPT: fixrate_summary.R"

Rscript $src/fixrate_summary.R

echo "SCRIPT COMPLETE: fixrate_summary.R"

# ------------ CBG area distribution ------------

echo "STARTING SCRIPT: cbg-area-distribution.R"

Rscript $src/cbg-area-distribution.R

echo "SCRIPT COMPLETE: cbg-area-distribution.R"

# ------------ dBBMM area distribution ------------

echo "STARTING SCRIPT: dbbmm-area-distribution.R"

Rscript $src/dbbmm-area-distribution.R

echo "SCRIPT COMPLETE: dbbmm-area-distribution.R"

# ------------ Extended data table 2 ------------

echo "STARTING SCRIPT: extended-data-table2.R"

Rscript $src/extended-data-table2.R

echo "SCRIPT COMPLETE: extended-data-table2.R"

echo "JOB COMPLETE"
