#!/bin/bash

for volume in b c d e f
do
  umount /dev/sd${volume}1
  umount /dev/sd${volume}2
done
