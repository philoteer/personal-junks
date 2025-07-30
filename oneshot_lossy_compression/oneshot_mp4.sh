#!/bin/bash	

export EXTENSION=mp4
export TARGET_EXTENSION=mp4
export EXEC_PATH="runnables/videoshrink.sh"
export QUAL_ARG=0  #not implemented (at the moment)
export NUM_PROCESS=4

bash oneshot_generic.sh
