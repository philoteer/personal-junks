#!/bin/bash	

export EXTENSION=ps
export TARGET_EXTENSION=pdf
export EXEC_PATH="runnables/psshrink.sh"
export QUAL_ARG=150 

bash oneshot_generic.sh
