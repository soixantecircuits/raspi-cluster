This a collection of scripts to build a cluster of many raspberry pi's.


# Instructions on using iso images for a setup of many raspberry pi.

We think that usb keys are more reliable than sd cards for many writing/reading instructions.
Therefore we use one SD card to boot the system, because raspi needs a sd card, and a usb key, for safety reasons.

As a bonus, it is easier to batch copy the system to many usb keys at once with a usb hub.

To check your usb path, check df -h, you should you see partitions with names like /dev/sdb /dev/sda 

## Requires
`sudo apt-get install pv`

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


# Copy an image to a usb key

Check that everything is working fine with one key.

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

# Batch copy an image to a usb key
If eveything went well, youc an start to copy many keys at once.
Plug all the usb hubs you have.

Edit batch-dd.sh, add all the letters of your plugged usb keys (remember, use `$ df -h` to find them.

If you have 5 keys plugged in, you should write something like

```
for volume in b c d e f
```
at line 3 and 8
Edit the name of your ISO image as well.

Then run the script
```
bash batch-dd.sh
```

Now it should take a long time to finish.
Check that it is still running with `ps aux | grep dd`

# Batch rename 
Now they all have the same name.
And you want them to have numbers to distinguish them when they are on the same network.
Add a physical number on each key.
Then plug them one by one in ascending order to your usb hubs.
This is a very critical operation you want to mess the numbering of your usb keys. You can not undo it.
Each time you plug a key in, make sure that the partition is auto mounted using `$ df -h`
If not, manually mount it.
Once you're done, edit the batch-rename.sh script to fit your needs.
Write the hostname of your primary key, the new hostname you want, the first number inserted and the last one.
Then
```
bash batch-rename.sh
```
It should take 1 sec. And you're done.
Plug the usb keys to the raspberry pi's and check them on the network.
