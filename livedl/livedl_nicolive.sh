#!/bin/bash

#update log
LOG_PATH="/home/piloteer/dl_log"
TIME="$(date +"%F") $(date +"%T")"
echo "$TIME	$$	DL $1" >> $LOG_PATH


#create and move in into the directory
dir_name="niconico_$(date +%Y%m%d_%H%M%S)"
mkdir $dir_name
cd $dir_name

#download
livedl -nico -no-chdir -nico-login "","" -nico-login-only=on -nico-auto-convert=on "$1" | tee stdout.txt

cat stdout.txt | grep "mp4" > list
sed -i s/$/\'/g list
sed -i s/^/file\ \'/ list
rm stdout.txt
#Check error message
OUT=$?

rm *.db
rm *.sqlite3
rm *.xml

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
if [ $OUT -eq 0 ]; then
        TIME="$(date +"%F") $(date +"%T")"
        echo "$TIME	$$	DL_END $1" >> $LOG_PATH
else
        TIME="$(date +"%F") $(date +"%T")"
        echo "$TIME	$$	DL_FAIL $1" >> $LOG_PATH
fi
