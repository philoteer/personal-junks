#!/bin/bash

#update log 
LOG_PATH="/home/piloteer/dl_log"
TIME="$(date +"%F") $(date +"%T")"
echo "$TIME	$$	DL $1" >> $LOG_PATH

#echo user name
s="$(echo "$1" | sed -e 's/.*\///g')"
echo "$s"

#create and move in into the directory
dir_name="${s}_$(date +%Y%m%d_%H%M%S)"
mkdir $dir_name
cd $dir_name

#livedl -tcas -no-chdir -tcas-retry=on "$1"

#for 10 times:
i="0"
while [ $i -lt 5 ]
do
	#try recording
	file_name="${s}_$(date +%Y%m%d_%H%M%S)"
	twitcas-dl "$s" -o "$file_name".ts
	sleep 40

	#delete the file if empty
	if [ ! -s "$file_name".ts ]
	then
		rm "$file_name".ts
	else
		ts_to_mp4 "${file_name}.ts" "${file_name}.mp4" & 
		echo "file '${file_name}.mp4'" >> list
		i="0"
	fi
i=$[$i+1]
done


#wait until conversions are done
#CCCV from https://stackoverflow.com/questions/3856747/check-whether-a-certain-file-type-extension-exists-in-directory
count=`ls -1 *.ts 2>/dev/null | wc -l`
while [ $count != 0 ]
do
	echo "waiting for the ffmpeg process.."
	sleep 10
	count=`ls -1 *.ts 2>/dev/null | wc -l`
done 

#this is from: https://unix.stackexchange.com/questions/90106/whats-the-most-resource-efficient-way-to-count-how-many-files-are-in-a-director
num_of_files=$(\ls -afq | wc -l)

#if no fie exists within the directory, move it outside and rmdir the directory
if [ $num_of_files -eq 3 ]
then
	rm list
	cd ..
	rmdir $dir_name
#if one file exist within the directory, move it outside and rmdir the directory
elif [ $num_of_files -eq 4 ]
then
	rm list
	mv * ../
	cd ..
	rmdir $dir_name

else
	files=( *.mp4 )
	ffmpeg_concat list "../concat_${files[0]}"

fi

#update log
TIME="$(date +"%F") $(date +"%T")"
echo "$TIME	$$	DL_END $1" >> $LOG_PATH
