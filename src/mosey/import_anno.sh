#!/bin/bash

#----
#---- Downloads annotated data from GCS and imports into local mosey database
#----

eval "$(docopts -h - : "$@" <<EOF
Usage: import_anno.sh [options] <argv> ...
Options:
			--help     Show help options.
			--version  Print program version.
			--table=<table>    Table to load the annotations into. Matches using event_id.
			--clean=<clean>   If true, deletes intermediate csv files. defaults to true.
----
import_anno.sh 0.1
EOF
)"

# gcsOutURL=${argv[0]}
# annoP=${argv[1]}
# db=${argv[2]}

# use bash syntax instead of zsh
gcsOutURL=$1
annoP=$2
db=$3

echo gcsOutURL: $gcsOutURL
echo annoP: $annoP
echo db: $db

# Set defaults
[[ -z "$table" ]] && table="event_trim"
[[ -z "$clean" ]] && clean="false"

endTx=commit
		
mkdir -p $annoP

#---- Load variables from control files

entity=study

# study.csv
names=($(mlr --csv --opprint filter '$run == 1' then cut -f study_id ctfs/$entity.csv | tail -n +2))

echo ${names[@]}

# envs.csv
envs=($(mlr --csv --opprint filter '$run == 1' then cut -f env_id ctfs/env.csv | tail -n +2))
colnames=($(mlr --csv --opprint filter '$run == 1' then cut -f col_name ctfs/env.csv | tail -n +2))

echo $envs[@]
echo $colnames[@]

for name in "${names[@]}"
do
	echo "*******"
	echo "Start processing $entity $name"
	echo "*******"
	
	# get length of an array
  n=${#envs[@]}

  for (( i=0; i<${n}; i++ ));
  do

    echo "Importing ${colnames[$i]}"
    
		annoN=${name}_${colnames[$i]}
		annoPF=$annoP/${annoN}.csv
		gcsCSV=$gcsOutURL/${annoN}/${annoN}.csv

		gsutil -q stat $gcsOutURL/${annoN}/${annoN}_*.csv

		return_value=$? #returns 0 if files exist, 1 if there are no results

		if [ $return_value = 1 ]; then
			echo "$gcsCSV does not exist. Skipping."
			continue
		fi
		
		echo "Downloading $gcsOutURL/${annoN}/${annoN}_*.csv ..."
		
		gsutil cp $gcsOutURL/${annoN}/${annoN}_*.csv $annoP

    echo "Merging individual task files..."
    awk '(NR == 1) || (FNR > 1)' $annoP/${annoN}_*.csv > $annoPF
    
		echo Updating the database...
		
		echo Transaction will $endTx
		
		sqlite3 $db <<-EOF
			begin;
			.mode csv temp_annotated

			.import $annoPF temp_annotated
      
			update $table
			set ${colnames[$i]} = t.${colnames[$i]}
			from temp_annotated t
			where t.anno_id = ${table}.event_id;
			
			update $table set ${colnames[$i]} = NULL where ${colnames[$i]}='';

			drop table temp_annotated;

			${endTx};
		EOF
    
		#---- Cleanup
		
    if [ $clean = "true" ]; then
      echo "Deleting temporary csv files."
      rm -f $annoP/${annoN}_*.csv
  		rm -f $annoPF
  	else
  	  echo "Did not delete intermediate csv files."
  	fi

		echo ${colnames[$i]} complete

	done
done

echo "Script complete"