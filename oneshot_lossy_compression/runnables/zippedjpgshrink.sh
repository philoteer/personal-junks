#!/bin/sh

# basic design and functions are based on:
# 
# http://www.alfredklomp.com/programming/shrinkpdf; which is
# Licensed under the 3-clause BSD license:
#
# Copyright (c) 2014-2019, Alfred Klomp
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


shrink ()
{
	dir_name="__tmp_zjs"
	unar -o $dir_name $1

	find ./${dir_name} -name '*.*' |

	while read f;
	do
		#taken from: http://www.imagemagick.org/discourse-server/viewtopic.php?t=34020
		#detect grayscale
		echo $f

		name=$(basename -- "$f")
		f_ext="${name##*.}"
		f_ext_tolower=$(echo $f_ext | tr '[:upper:]' '[:lower:]')
		
		if [ "$f_ext_tolower" = "gif" ] || [ "$f_ext_tolower" = "jpg" ] || [ "$f_ext_tolower" = "jpeg" ];
		then
			f_out="$f"
		else
			f_out="${f}.jpg"
		fi

		#prevent html2ps
		if [ $f_ext_tolower = "htm" ] || [ $f_ext_tolower = "html" ];
		then
			continue;
		fi


		#leave psd files alone.
		if [ $f_ext_tolower = "psd" ];
		then
			continue;
		fi

		COLOUREDNESS=$(convert "$f" -colorspace HCL -format %[fx:mean.g] info:)

		FOO=$(echo "$COLOUREDNESS > 0.02" |bc -l)

		if [ $FOO = 0 ];
		then
			#grayscale
			convert "$f"  -strip -quality $3 -interlace JPEG -colorspace Gray -resize "x1200>" "$f_out"
		else
			#color
			convert "$f" -sampling-factor 4:2:0 -strip -quality $3 -interlace JPEG -colorspace RGB -resize "x1200>" "$f_out"
		fi

		
		#rm the original file if necessary
		if [ "$f" = "$f_out" ];
		then
			continue
		else
			if [ -f "$f_out" ]; then
				rm "$f"
			fi
		fi
			
	done
	
	zip -r $2 ./${dir_name}

	rm -rf $dir_name

}

check_smaller ()
{
	# If $1 and $2 are regular files, we can compare file sizes to
	# see if we succeeded in shrinking. If not, we copy $1 over $2:
	if [ ! -f "$1" -o ! -f "$2" ]; then
		return 0;
	fi
	
	if [ ! -z "$3" ]; then
		SIZE_REQ="$3"
	else
		SIZE_REQ="100"
	fi
	
	ISIZE="$(echo $(wc -c "$1") | cut -f1 -d\ )"
	OSIZE="$(echo $(wc -c "$2") | cut -f1 -d\ )"
	MIN_DESIRED_OSIZE=`expr \( $ISIZE \* $SIZE_REQ \) / 100`
	
	if [ "$MIN_DESIRED_OSIZE" -lt "$OSIZE" ]; then
		echo "Input smaller than desired; doing straight copy" >&2
		cp "$1" "$2"
	fi
}


usage ()
{
	echo "  Usage: $1 infile [outfile] [quality]"
}

IFILE="$1"

# Need an input file:
if [ -z "$IFILE" ]; then
	usage "$0"
	exit 1
fi

# Output filename defaults to "-" (stdout) unless given:
if [ ! -z "$2" ]; then
	OFILE="$2"
else
	OFILE="-"
fi

if [ ! -z "$3" ]; then
	res="$3"
else
	res="70"
fi

if [ ! -z "$4" ]; then
	size_req="$4"
else
	size_req="100"
fi

shrink "$IFILE" "$OFILE" "$res" || exit $?

check_smaller "$IFILE" "$OFILE" $size_req
