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
  #convert $1 -sampling-factor 4:2:0 -strip -quality $3 -interlace JPEG -colorspace RGB -resize "x1200>" $2
  $ffmpeg -y -i "$1" -threads 0 -sn -c:v libaom-av1 -cpu-used 4 -row-mt true -crf 30 -tile-columns 1 -tile-rows 1 -sws_flags lanczos -vf "scale=w=min(iw\,1280):h=-2" -c:a libopus -strict normal -ac 2 -ab 128k -r 23.98 "$2" 
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


ffmpeg="ffmpeg"


shrink "$IFILE" "$OFILE" "$res" || exit $?

check_smaller "$IFILE" "$OFILE" $size_req
