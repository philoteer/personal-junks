#!/bin/sh

for F in "$@"
do 
	dir=$(dirname "$F")
	filename=$(basename -- "$F")
	filename_noext="${filename%.*}"
	
	echo "###### ${filename} ######"	
	mkdir -p "${dir}/png"	

	pdftoppm -png "$F" "${dir}/png/${filename_noext}"
done
