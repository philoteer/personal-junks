#!/bin/bash	

#(for now, some bashisms are going on)

#list of variables
#EXTENSION=ps
#TARGET_EXTENSION=pdf
#EXEC_PATH="pdfshrink.sh"
#QUAL_ARG=150 

TMP_FILENAME_1="__1.${EXTENSION}"	#original file (temporarily copied)
TMP_FILENAME_2="__2.${TARGET_EXTENSION}"	#output file
TMP_LIST_FILENAME="__${EXTENSION}_list"

#get file list
echo "Creating a file list."
find . -iname "*.$EXTENSION" > "$TMP_LIST_FILENAME"
LINES_COUNT=$(wc -l "$TMP_LIST_FILENAME" | awk '{print $1}')

#exec functionality check
echo "Verifying the functionality of the converter program."
first_file=$(head -n 1 "$TMP_LIST_FILENAME")
cp "$first_file" "$TMP_FILENAME_1" 
sh "$EXEC_PATH" "$TMP_FILENAME_1"  "$TMP_FILENAME_2" || { echo 'something is wrong' ; exit 1; }
rm "$TMP_FILENAME_1"  "$TMP_FILENAME_2"

echo "converter is working; proceeding to the actual conversion stage."

#Do the actual task.
IFS=$'\n'
CURRENT_COUNT=1
for j in $(cat "./$TMP_LIST_FILENAME")
do
	echo "[$CURRENT_COUNT/$LINES_COUNT] $j"
	cp "$j" "$TMP_FILENAME_1"  #used to be mv instead; changed to minimize chance of losing files. 
	#sh $EXEC_PATH "$TMP_FILENAME_1" "$TMP_FILENAME_2"|| { echo 'something is wrong' ; exit 1; }
	sh "$EXEC_PATH" "$TMP_FILENAME_1"  "$TMP_FILENAME_2" $QUAL_ARG || CURRENT_COUNT=`expr $CURRENT_COUNT + 1`; continue
	rm "$TMP_FILENAME_1" 
	rm "$j"
	
	if [ $EXTENSION == $TARGET_EXTENSION ]
	then
		mv "$TMP_FILENAME_2" "$j"
	else
		mv "$TMP_FILENAME_2" "${j}.${TARGET_EXTENSION}"
	fi
	
	CURRENT_COUNT=`expr $CURRENT_COUNT + 1`
done

#remove the tmp file.
rm "$TMP_LIST_FILENAME"
