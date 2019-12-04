#!/bin/bash 
#Some bashisms going on.
#refs: https://stackoverflow.com/questions/4638874/how-to-loop-through-a-directory-recursively-to-delete-files-with-certain-extensi

IFS=$'\n'; set -f

ZIP_EXISTS=1

while [ $ZIP_EXISTS -gt 0 ]; do
	for f in  $(find ./ -name '*.zip' -or -name '*.rar')
	do
		unar -e cp949 $f
		rm $f
		ZIP_EXISTS=1
	done
	ZIP_EXISTS=0
done
unset IFS; set +f


IFS=$'\n'; set -f

for f in  $(find ./ -name '*.*')	#change to image file extensions 
do
	#taken from: http://www.imagemagick.org/discourse-server/viewtopic.php?t=34020
	#detect grayscale
	COLOUREDNESS=$(convert $f -colorspace HCL -format %[fx:mean.g] info:)

	if (( $(echo "$COLOUREDNESS > 0.02" |bc -l) ))
	then
		#color
		convert $f -sampling-factor 4:2:0 -strip -quality 70 -interlace JPEG -colorspace RGB -resize "x1200>" $f
	else
		#grayscale
		convert $f  -strip -quality 70 -interlace JPEG -colorspace Gray -resize "x1200>" $f
	fi
	
done
unset IFS; set +f
