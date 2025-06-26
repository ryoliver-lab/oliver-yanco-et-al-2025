# Runs annotation script for each study in study.csv and environmental variable 
# in envs array

#argv[0]  <geePtsP> Folder holding the gee point datasets
#argv[1]  <gcsOutP> Path to the output folder for annotated csvs (excluding bucket)

eval "$(docopts -h - : "$@" <<EOF
Usage: mosey_anno_gee.sh [options] <argv> ...
Options:
      --help     Show help options.
      --version  Print program version.
----
mosey_anno_gee 0.1
EOF
)"

# geePtsP=${argv[0]}
# gcsOutP=${argv[1]}

# use bash syntax instead of zsh
geePtsP=$1
gcsOutP=$2
# geePtsp=$geePtsP
# gcsOutP=$gcsOutP

# Use miller to filter by run column and then take the study_id field
# as well as env information
# need to use tail to remove first line, which is the header

#----Load variables from control files

# study.csv
studyIds=($(mlr --csv --opprint filter '$run == 1' then cut -f study_id ctfs/study.csv | tail -n +2))

# env.csv
envs=($(mlr --csv --opprint filter '$run == 1' then cut -f env_id ctfs/env.csv | tail -n +2))
bands=($(mlr --csv --opprint filter '$run == 1' then cut -f band ctfs/env.csv | tail -n +2))
colnames=($(mlr --csv --opprint filter '$run == 1' then cut -f col_name ctfs/env.csv | tail -n +2))

# Remove \r suffix
studyIds=( ${studyIds[@]%$'\r'} )
envs=( ${envs[@]%$'\r'} )
bands=( ${bands[@]%$'\r'} )
colnames=( ${colnames[@]%$'\r'} )

echo Annotating ${#studyIds[@]} studies.

for studyId in "${studyIds[@]}"

do 
  echo "*******"
  echo "Start processing study ${studyId}"
  echo "*******"
  
  points=$geePtsP/$studyId
  
  # get length of an array
  n=${#envs[@]}

  # use for loop to read all values and indexes
  for (( i=0; i<${n}; i++ ));
  do

    out=$gcsOutP/${studyId}_${colnames[$i]} # do not include url, bucket, or file extension
    
    echo Annotating "env: ${envs[$i]}, band: ${bands[$i]}, col name: ${colnames[$i]}"
    
    $MOSEYENV_SRC/gee_anno.r $points $out $studyId ${envs[$i]} ${colnames[$i]} ${bands[$i]}
  done

done
