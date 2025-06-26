#!/bin/bash

#SBATCH -t 04:00:00
#SBATCH --job-name part1_step1
#SBATCH --mem 300GB  

# set up paths for wd, src, R version, and conda env
source config1.env
cd $wd

# copy database from mosey output to ./raw_data
cp $mosey_db_raw $wd/raw_data/mosey.db
# copy database to /tmp on worker node
cp $wd/raw_data/mosey.db /tmp/mosey_mod.db

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

# ------------ Process safegraph data ------------

echo "STARTING SCRIPT: process-safegraph-data.r"

Rscript $src_part1/process-safegraph-data.r

echo "SCRIPT COMPLETE: process-safegraph-data.r"

# ------------ Remove some skunk data ------------

echo "STARTING SCRIPT: adjust_skunk_data.R"

Rscript $src_part1/adjust_skunk_data.R

echo "SCRIPT COMPLETE: adjust_skunk_data.R"

# ------------ Trimming ------------

echo "STARTING SCRIPT: trim_data.r" 

Rscript $src_part1/trim_data.r

echo "SCRIPT COMPLETE: trim_data.r"

cp /tmp/mosey_mod.db $wd/processed_data/mosey_mod.db

echo "JOB COMPLETE"
