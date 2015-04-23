#!/bin/bash
for volume in b c 
do
  umount /dev/sd${volume}1
  umount /dev/sd${volume}2
done
for volume in b c; do echo $volume; done | parallel dd bs=4M count=450 if=chow-chowXX.iso | pv | sudo dd of=/dev/sd{}
sync
