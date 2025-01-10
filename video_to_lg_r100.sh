#!/bin/sh
# original source: https://nurdspace.nl/LG_R100_info_collection

ENCODER="libx264"
#ENCODER="h264_nvenc"
#vaapi does not work (not sure how to fix this)

#stretch
ffmpeg -i "$1" -filter:v "transpose=1,scale=640:720,setsar=1" -codec:v $ENCODER -f matroska -y _left.mkv
ffmpeg -i "$1" -filter:v "transpose=2,scale=640:720,setsar=1" -codec:v $ENCODER -f matroska -y _right.mkv

ffmpeg -i _left.mkv -i _right.mkv -filter_complex hstack -codec:v $ENCODER "$1_R100.mkv"
rm _left.mkv
rm _right.mkv

#playback: mplayer -monitorpixelaspect 1.5 rollercoaster-LGR100.mp4
