#!/bin/bash

#available freqs: /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
freq=1600000
num_cores=16

loop_end="$((num_cores-1))"

for i in $(seq 0 1 $loop_end)
do
	echo $freq | sudo tee /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_max_freq
done
