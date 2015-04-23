#!/bin/bash
sleep 5
umount /dev/mmcblk0p1 
sleep 5
dd bs=4M if=boot.iso | pv | sudo dd of=/dev/mmcblk0
sleep 5
sync
