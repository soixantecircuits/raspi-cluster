This a collection of scripts to build a cluster of many raspberry pi's.

# Copy a system from a usb key to your computer.

If you already have a ISO image. Skip this step.

Open the usb key in gparted to reduce partition size to less than 1800 MB
Then find the path of your key using `$ df -h`
In this example, our key is /dev/sdc

```
umount /dev/sdc1
umount /dev/sdc2
sudo dd bs=4M count=450 if=/dev/sdc | pv | dd of=my-raspi-system.iso
sync
```


# Instructions on using iso images for a setup of many raspberry pi.

We think that usb keys are more reliable than sd cards for many writing/reading instructions.
Therefore we use one SD card to boot the system, because raspi needs a sd card, and a usb key, for safety reasons.

As a bonus, it is easier to batch copy the system to many usb keys at once with a usb hub.

To check your usb path, check df -h, you should you see partitions with names like /dev/sdb /dev/sda 

## Requires
`sudo apt-get install pv`

# Copy an image to a usb key
```
umount /dev/sdc1
umount /dev/sdc2
dd bs=4M count=450 if=my-raspi-system.iso | pv | sudo dd of=/dev/sdc
sync
```

# Copy the boot image to a sd card
```
umount /dev/sdb1
umount /dev/sdb2
dd bs=4M count=450 if=boot.iso | pv | sudo dd of=/dev/sdb
sync
```

