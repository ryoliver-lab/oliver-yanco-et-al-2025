#!/bin/bash

#SBATCH -t 48:00:00
#SBATCH --job-name part1_step4
#SBATCH -c 32
#SBATCH --mem=300G 
##SBATCH --nodelist=node53
##SBATCH --partition=largemem
##SBATCH --mem-per-cpu=112G

# set up paths for wd, src, R version, and conda env
source config1.env
cd $wd

# copy database to /tmp on worker node
cp $mosey_db_clean /tmp/mosey_mod.db

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


# ------------ Calculate Responses - Space Use - Fit dBBMMs ------------

# Make log file to track successful outputs
echo "species, ind_id, study_id, year, out_type, filename, produced, out_date" > $wd/out/dbbmm_log.csv
  
# Make big mem log file to track ind-year combos saved for the big mem parition
echo "species, ind_id, study_id, year, out_type, filename, produced, out_date" > $wd/out/dbbmm_bigmem_log.csv

# Make log file to track how many individual and year pairs do not exist in the event data
echo "study_id, individual_id, year" > $wd/out/no_ind_yr_pairs.csv

echo "STARTING SCRIPT: fit-dBBMMs.r"

Rscript $src_part1/fit-dBBMMs.r /tmp/mosey_mod.db $wd/out 7

echo "SCRIPT COMPLETE: fit-dBBMMs.r"


# ------------ Calculate Responses - Space Use - Calculate dBBMM areas and collate environment ------------

echo "species, ind_id, study_id, year, wk, area, sg, ghm, cbg_area, ndvi, tmax, n, a_bb, fixmed, m_error" > $wd/out/dbbmm_size.csv

echo "STARTING SCRIPT: calc-space-use.r"

Rscript $src_part1/calc-space-use.r $wd/out /tmp/mosey_mod.db $wd/out/dbbmm_log.csv 24 -c

echo "SCRIPT COMPLETE: calc-space-use.r"


# ------------ Calculate Responses - Niche Breadth - Calculate MVNH Breadth ------------

# Create csv to store results with column names specified beforehand
# (this will overwrite the existing CSV if it already exists)
echo "total, tmax, ndvi, elev, cor, week, individual, scientificname, studyid, year, n" > $wd/out/MVNH_size.csv
# Make log file to track successful outputs
echo "studyid, individual, scientificname, year, status, week" > $wd/out/niche_log.csv

echo "STARTING SCRIPT: calc-niche-breadth.r"

Rscript $src_part1/calc-niche-breadth.r /tmp/mosey_mod.db ./out/MVNH_size.csv 24

echo "SCRIPT COMPLETE: calc-niche-breadth.r"

# ------------ Niche breadth sensitivity: subsample of 50 ------------

echo "STARTING SCRIPT: calc-niche-breadth-subsample.r for sample size 50"

echo "total, tmax, ndvi, elev, cor, week, individual, scientificname, studyid, year, n" > $wd/out/niche_subsamples/MVNH_subsample_50.csv

echo "studyid, individual, scientificname, year, status, week" > $wd/out/niche_subsamples/niche_subsample_log_50.csv

Rscript $src_part1/calc-niche-breadth-subsample.r /tmp/mosey_mod.db ./out/niche_subsamples/MVNH_subsample_50.csv 24 50

echo "SCRIPT COMPLETE: calc-niche-breadth-subsample.r for sample size 50"

# ------------ Niche breadth sensitivity: subsample of 40 ------------

echo "STARTING SCRIPT: calc-niche-breadth-subsample.r for sample size 40"

echo "total, tmax, ndvi, elev, cor, week, individual, scientificname, studyid, year, n" > $wd/out/niche_subsamples/MVNH_subsample_40.csv

echo "studyid, individual, scientificname, year, status, week" > $wd/out/niche_subsamples/niche_subsample_log_40.csv

Rscript $src_part1/calc-niche-breadth-subsample.r /tmp/mosey_mod.db ./out/niche_subsamples/MVNH_subsample_40.csv 24 40

echo "SCRIPT COMPLETE: calc-niche-breadth-subsample.r for sample size 40"

# ------------ Niche breadth sensitivity: subsample of 30 ------------

echo "STARTING SCRIPT: calc-niche-breadth-subsample.r for sample size 30"

echo "total, tmax, ndvi, elev, cor, week, individual, scientificname, studyid, year, n" > $wd/out/niche_subsamples/MVNH_subsample_30.csv

echo "studyid, individual, scientificname, year, status, week" > $wd/out/niche_subsamples/niche_subsample_log_30.csv

Rscript $src_part1/calc-niche-breadth-subsample.r /tmp/mosey_mod.db ./out/niche_subsamples/MVNH_subsample_30.csv 24 30

echo "SCRIPT COMPLETE: calc-niche-breadth-subsample.r for sample size 30"

# ------------ Niche breadth sensitivity: subsample of 20 ------------

echo "STARTING SCRIPT: calc-niche-breadth-subsample.r for sample size 20"

echo "total, tmax, ndvi, elev, cor, week, individual, scientificname, studyid, year, n" > $wd/out/niche_subsamples/MVNH_subsample_20.csv

echo "studyid, individual, scientificname, year, status, week" > $wd/out/niche_subsamples/niche_subsample_log_20.csv

Rscript $src_part1/calc-niche-breadth-subsample.r /tmp/mosey_mod.db ./out/niche_subsamples/MVNH_subsample_20.csv 24 20

echo "SCRIPT COMPLETE: calc-niche-breadth-subsample.r for sample size 20"

# ------------ Niche breadth sensitivity: subsample of 10 ------------

echo "STARTING SCRIPT: calc-niche-breadth-subsample.r for sample size 10"

echo "total, tmax, ndvi, elev, cor, week, individual, scientificname, studyid, year, n" > $wd/out/niche_subsamples/MVNH_subsample_10.csv

echo "studyid, individual, scientificname, year, status, week" > $wd/out/niche_subsamples/niche_subsample_log_10.csv

Rscript $src_part1/calc-niche-breadth-subsample.r /tmp/mosey_mod.db ./out/niche_subsamples/MVNH_subsample_10.csv 24 10

echo "SCRIPT COMPLETE: calc-niche-breadth-subsample.r for sample size 10"

# ------------ Fix rate ------------

echo "study_id, species, individual_id, year, fix_rate_med, fix_rate_min, fix_rate_max" > $wd/out/fixrate_med_min_max.csv

echo "STARTING SCRIPT: fix_rate_fig.r"

Rscript $src_part1/fix_rate_fig.r /tmp/mosey_mod.db $wd/out 7

echo "SCRIPT COMPLETE: fix_rate_fig.r"

echo "JOB COMPLETE"