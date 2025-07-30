#!/bin/bash
# Parallel for ref: https://stackoverflow.com/questions/38774355/how-to-parallelize-for-loop-in-bash-limiting-number-of-processes

FFMPEG_BIN="/home/piloteer/ffmpeg-5.0.1-amd64-static/ffmpeg"
NUM_PROCESS=4
num_jobs="\j"

for F in "$@"
do 
	while (( ${num_jobs@P} >= NUM_PROCESS )); do
		wait -n
	done

	dir=$(dirname "$F")
	filename=$(basename -- "$F")
	filename_noext="${filename%.*}"
	
	echo "###### ${filename} ######"	
	mkdir -p "${dir}/enc"
	#$FFMPEG_BIN -y -i "$F" -threads 0 -sn -vcodec libx264 -preset slower -crf 25 -tune animation -sws_flags lanczos -vf "scale=w=min(iw\,1280):h=-2" -acodec aac -strict experimental -ac 2 -ab 128k -r 23.98 "${dir}/enc/${filename_noext}.mp4"
	
	$FFMPEG_BIN -y -i "$F" -threads 0 -sn -c:v libaom-av1 -cpu-used 4 -row-mt true -crf 30 -tile-columns 1 -tile-rows 1 -sws_flags lanczos -vf "scale=w=min(iw\,1280):h=-2" -c:a libopus -strict normal -ac 2 -ab 128k -r 23.98 "${dir}/enc/${filename_noext}.mp4" &
	
done
