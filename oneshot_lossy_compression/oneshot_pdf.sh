#!/bin/bash

#get pdf list
echo "Creating a file list."
find . -name "*.pdf" > pdf_list

#shrinkpdf functionality check
echo "Verifying the functionality of shrinkpdf script."
first_file=$(head -n 1 pdf_list)
cp "$first_file" 1.pdf 
./pdfshrink.sh 1.pdf 2.pdf || { echo 'something is wrong' ; exit 1; }
rm 1.pdf 2.pdf

echo "shrinkpdf is working; proceeding to the actual conversion stage."

#Do the actual task.
IFS=$'\n'
for j in $(cat ./pdf_list)
do
	echo "$j"
	mv "$j" 1.pdf
	#shrinkpdf 1.pdf 2.pdf || { echo 'something is wrong' ; exit 1; }
	./pdfshrink.sh 1.pdf 2.pdf
	rm 1.pdf
	mv 2.pdf "$j"
done

#remove the tmp file.
rm pdf_list
