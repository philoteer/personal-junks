#!/bin/bash	

export EXTENSION=pdf
export TARGET_EXTENSION=pdf
export EXEC_PATH="runnables/pdfshrink.sh"
export QUAL_ARG=150 
export NUM_PROCESS=4

bash oneshot_generic.sh
