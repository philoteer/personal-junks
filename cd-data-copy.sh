#!/bin/sh

sudo umount /dev/sr*

#(in case of unclean exit)
for i in /mnt/cd*; do
	sudo rmdir "$i"
done

#do the ripping
CNT=0
for i in /dev/sr*; do
	sudo mkdir "/mnt/cd_$CNT"
	sudo mount "$i" "/mnt/cd_$CNT"
	cp -R "/mnt/cd_$CNT" $1 &
	CNT=$((CNT+1))
done

#sync
echo "waiting.."
wait

#cleanup
for i in /mnt/cd*; do
	sudo umount "$i"
	sudo rmdir "$i"
done

#sudo chmod -R 777 "$1/cd_*"

for i in /dev/sr*; do
	eject $i
done

#play beep.wav
xmessage -center "Done (hopefully)."
