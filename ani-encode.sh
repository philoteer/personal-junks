#!/bin/sh

FFMPEG_BIN="/home/piloteer/ffmpeg-5.0.1-amd64-static/ffmpeg"

for F in "$@"
do 
	dir=$(dirname "$F")
	filename=$(basename -- "$F")
	filename_noext="${filename%.*}"
	
	echo "###### ${filename} ######"	
	mkdir -p "${dir}/enc"
	#$FFMPEG_BIN -y -i "$F" -threads 0 -sn -vcodec libx264 -preset slower -crf 25 -tune animation -sws_flags lanczos -vf "scale=w=min(iw\,1280):h=-2" -acodec aac -strict experimental -ac 2 -ab 128k -r 23.98 "${dir}/enc/${filename_noext}.mp4"
	
	$FFMPEG_BIN -y -i "$F" -threads 0 -sn -c:v libaom-av1 -cpu-used 4 -row-mt true -crf 30 -tile-columns 1 -tile-rows 1 -sws_flags lanczos -vf "scale=w=min(iw\,1280):h=-2" -acodec aac -strict experimental -ac 2 -ab 128k -r 23.98 "${dir}/enc/${filename_noext}.mp4"
	
done
