#!/bin/bash

for volume in b c d e f
do
  umount /dev/sd${volume}1
  umount /dev/sd${volume}2
done
for volume in b c d e f; do echo $volume; done | sudo parallel dd bs=4M count=450 if=chow-chowXX-MQ.iso of=/dev/sd{}
sync
