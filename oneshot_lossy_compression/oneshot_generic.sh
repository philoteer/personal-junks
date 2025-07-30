#!/bin/bash	
# Parallel for ref: https://stackoverflow.com/questions/38774355/how-to-parallelize-for-loop-in-bash-limiting-number-of-processes

#list of variables
if [ -z ${SIZE_ARG} ]; then 
	SIZE_ARG=80
fi

if [ -z ${NUM_PROCESS} ]; then 
	NUM_PROCESS=1
fi
num_jobs="\j"

#echo "$SIZE_ARG $NUM_PROCESS"

TMP_LIST_FILENAME="__${EXTENSION}_list"

#get file list
echo "Creating a file list."
find . -iname "*.$EXTENSION" > "$TMP_LIST_FILENAME"
LINES_COUNT=$(wc -l "$TMP_LIST_FILENAME" | awk '{print $1}')

#exec functionality check
echo "Verifying the functionality of the converter program."
first_file=$(head -n 1 "$TMP_LIST_FILENAME")
cp "$first_file" "__1.${EXTENSION}" 


sh "$EXEC_PATH" "__1.${EXTENSION}"  "__2.${TARGET_EXTENSION}" $QUAL_ARG $SIZE_ARG || { echo 'something is wrong' ; exit 1; }

if [ ! -f "__2.${TARGET_EXTENSION}" ]; then
	rm "__1.${EXTENSION}"
	echo 'something is very wrong'
	exit 2
fi

rm "__1.${EXTENSION}"  "__2.${TARGET_EXTENSION}"

echo "converter is working; proceeding to the actual conversion stage."

#Do the actual task.
IFS=$'\n'
CURRENT_COUNT=1

function process() {
	_j="${1}"
	_EXEC_PATH="${2}"
	_TMP_FILENAME_1="${3}"
	_TMP_FILENAME_2="${4}"
	_QUAL_ARG="${QUAL_ARG}"
	_SIZE_ARG="${SIZE_ARG}"
	_EXTENSION="${EXTENSION}"
	_TARGET_EXTENSION="${TARGET_EXTENSION}"
	
	cp "${_j}" "${_TMP_FILENAME_1}"  #used to be mv instead; changed to minimize chance of losing files. 
	
	bash "$_EXEC_PATH" "$_TMP_FILENAME_1"  "$_TMP_FILENAME_2" $_QUAL_ARG $_SIZE_ARG || return 1
	rm "$_TMP_FILENAME_1" 
	

	if [ ! -f "$_TMP_FILENAME_2" ]; then
		echo 'something is very wrong'
		return 1
	fi

	rm "$_j"

	if [ $_EXTENSION == $_TARGET_EXTENSION ]
	then
		mv "$_TMP_FILENAME_2" "$_j"
	else
		mv "$_TMP_FILENAME_2" "${_j}.${_TARGET_EXTENSION}"
	fi
}

for j in $(cat "./$TMP_LIST_FILENAME")
do

	while (( ${num_jobs@P} >= NUM_PROCESS )); do
		wait -n
	done
	
	echo "[$CURRENT_COUNT/$LINES_COUNT] $j"
	
	process "${j}" "${EXEC_PATH}" "${CURRENT_COUNT}__1.${EXTENSION}" "${CURRENT_COUNT}__2.${TARGET_EXTENSION}" &
	
	
	CURRENT_COUNT=`expr $CURRENT_COUNT + 1`
done


while (( ${num_jobs@P} >= 1 )); do
	wait -n
done

#remove the tmp file.
rm "$TMP_LIST_FILENAME"

DIFF_COUNT=`expr $LINES_COUNT - $CURRENT_COUNT + 1`
echo "Skipped files (due to errors): $DIFF_COUNT"
