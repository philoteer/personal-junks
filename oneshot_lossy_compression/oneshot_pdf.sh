#!/bin/bash	

#(for now, some bashisms are going on)

#list of variables
TMP_FILENAME_1=__1.pdf
TMP_FILENAME_2=__2.pdf
TMP_LIST_FILENAME=__pdf_list

DPI=150
SHRINKPDF_PATH="pdfshrink.sh"

#get pdf list
echo "Creating a file list."
find . -iname "*.pdf" > "$TMP_LIST_FILENAME"
LINES_COUNT=$(wc -l "$TMP_LIST_FILENAME" | awk '{print $1}')

#shrinkpdf functionality check
echo "Verifying the functionality of shrinkpdf script."
first_file=$(head -n 1 "$TMP_LIST_FILENAME")
cp "$first_file" "$TMP_FILENAME_1" 
sh "$SHRINKPDF_PATH" "$TMP_FILENAME_1"  "$TMP_FILENAME_2" || { echo 'something is wrong' ; exit 1; }
rm "$TMP_FILENAME_1"  "$TMP_FILENAME_2"

echo "shrinkpdf is working; proceeding to the actual conversion stage."

#Do the actual task.
IFS=$'\n'
CURRENT_COUNT=1
for j in $(cat "./$TMP_LIST_FILENAME")
do
	echo "[$CURRENT_COUNT/$LINES_COUNT] $j"
	cp "$j" "$TMP_FILENAME_1"  #used to be mv instead; changed to minimize chance of losing files. 
	#shrinkpdf "$TMP_FILENAME_1" "$TMP_FILENAME_2"|| { echo 'something is wrong' ; exit 1; }
	sh "$SHRINKPDF_PATH" "$TMP_FILENAME_1"  "$TMP_FILENAME_2" $DPI
	rm "$TMP_FILENAME_1" 
	rm "$j"
	mv "$TMP_FILENAME_2" "$j"
	
	CURRENT_COUNT=`expr $CURRENT_COUNT + 1`
done

#remove the tmp file.
rm "$TMP_LIST_FILENAME"
