#!/bin/bash

for volume in b h i j k l
do
  umount /dev/sd${volume}1
  umount /dev/sd${volume}2
done
for volume in b h i j k l; do echo $volume; done | sudo parallel dd bs=4M if=/home/mina/Downloads/snapboxXX.iso of=/dev/sd{}
sync
