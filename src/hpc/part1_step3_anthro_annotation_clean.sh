#!/bin/bash

#SBATCH -t 05:00:00
#SBATCH --job-name part1_step3
#SBATCH --mem 300G

# set up paths for wd, src, R version, and conda env
source config1.env
cd $wd

# copy database to /tmp on worker node
cp $wd/processed_data/mosey_mod.db /tmp/mosey_mod.db

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


# ------------ Filtering for Minimums ------------

echo "STARTING SCRIPT: filter_data_mins.R" 

Rscript $src_part1/filter_data_mins.R --db /tmp/mosey_mod.db 30 3

echo "SCRIPT COMPLETE: filter_data_mins.R. Archiving database in /scratch."

# copy intermediate version of modified database to perisistent storage
cp /tmp/mosey_mod.db $wd/processed_data/intermediate_db_copies/mosey_mod_filter-data-mins_complete.db


# ------------ Intersect events with Census Block Group geometries ------------

echo "STARTING SCRIPT: intersect-events-cbg.r"

Rscript $src_part1/intersect-events-cbg.r

echo "SCRIPT COMPLETE: intersect-events-cbg.r."


# ------------ Compute Census Block Group area ------------

echo "STARTING SCRIPT: compute-cbg-area.r"

Rscript $src_part1/compute-cbg-area.r

echo "SCRIPT COMPLETE: compute-cbg-area.r."


# ------------ Annotate Census Block Groups ------------

echo "STARTING SCRIPT: annotate-events-cbg.r"

Rscript $src_part1/annotate-events-cbg.r

echo "SCRIPT COMPLETE: annotate-events-cbg.r."


# ------------ Annotate events with SafeGraph ------------

echo "STARTING SCRIPT: annotate-events-safegraph.r"

Rscript $src_part1/annotate-events-safegraph.r

echo "SCRIPT COMPLETE: annotate-events-safegraph.r."


# ------------ Annotate Events with Human Modification ------------

echo "STARTING SCRIPT: annotate-events-ghm.r"

Rscript $src_part1/annotate-events-ghm.r

echo "SCRIPT COMPLETE: annotate-events-ghm.r."


# ------------ Clean Data ------------

echo "STARTING SCRIPT: clean_movement.r"

Rscript $src_part1/clean_movement.r --db /tmp/mosey_mod.db

echo "SCRIPT COMPLETE: clean_movement.r. Archiving database in /scratch."

cp /tmp/mosey_mod.db $wd/processed_data/intermediate_db_copies/mosey_mod_clean-movement_complete.db

echo "JOB COMPLETE"
