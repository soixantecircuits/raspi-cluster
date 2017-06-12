#!/bin/bash

for volume in b h i j k l
do
  umount /dev/sd${volume}1
  umount /dev/sd${volume}2
done
