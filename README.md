This a collection of scripts to build a cluster of many raspberry pi's.


# Instructions on using iso images for a setup of many raspberry pi.

We think that usb keys are more reliable than sd cards for many writing/reading instructions.
As raspi needs a sd card for booting, we use one. The usb key is used for the system. This is for **safety reasons**.

As a bonus, it is easier to batch copy the system to many usb keys at once with a usb hub.

To check your usb path use `df -h`. You should you see partitions with names like `/dev/sdb.../dev/sda`.

## Requires

`sudo apt-get install pv`

# <a name="step-0"></a>Step 0 - Copy a system from a usb key to your computer.

If you already have a ISO image (or we provide one for you) you can skip this step and directly go to [Step 1](#step-1). 
If you need a system please read bellow.

## Operation a : reduce partition size
Open the usb key in `gparted` to reduce partition size to less than `1800 MB`. This will allow a faster copy.
Then find the path of your key using `$ df -h`

In this example, our key is /dev/sdc

## Operation b : unmount
```
umount /dev/sdc1
umount /dev/sdc2
```

## Operation c : copy on your disk
Then copy on your disk: 

```
sudo dd bs=4M count=450 if=/dev/sdc | pv | dd of=my-raspi-system.iso
sync
```

# <a name="step-1"></a>Step 1 - Copy a raspbery system image to an usb key

Be carreful and verify that everything is working fine with one usb key.

## Operation a : unmount desired key

```
umount /dev/sdc1
umount /dev/sdc2
```

## Operation b : copy from your disk to the usb key
```
dd bs=4M count=450 if=my-raspi-system.iso | pv | sudo dd of=/dev/sdc
sync
```

## Operation c : copy the boot image to a sd card

unmount:
```
umount /dev/sdb1
umount /dev/sdb2
```

and then copy on the sdcard: 
```
dd bs=4M count=450 if=boot.iso | pv | sudo dd of=/dev/sdb
sync
```

# <a name="step-2"></a>Step 2 - Batch copy an image to a usb key

If eveything went well and you are sure of what your are doing, you can start to copy many keys at once.

## Operation a: plug the usb hub to the computer (4 should be enough)

Plug all the usb hubs you have to the computer.

## Operation b: Edit the batch-dd.sh script

Edit `batch-dd.sh` in this directory, and add all the letters of your plugged usb keys (remember, use `$ df -h` to find them.
You do not need specific order of manual plug at this time, just plug and plug.

If you have 5 keys plugged in, you should write something like:

```
for volume in b c d e f
```

At line 3 and 8 [link](https://github.com/soixantecircuits/raspi-cluster/blob/master/batch-dd.sh#L8), edit the name of your ISO image as well. Instead of `chow-chowXX-MQ.iso` or what ever it is written down, type the name of your image disk.

## Operation c: run the script

```
bash batch-dd.sh
```

This will take a long time to finish. Depending on the machine you are using and on the usb key you bought, this operation could go from 40 minutes for 20 usb key up to 1h30.

You can check that it is still running with `ps aux | grep dd`.

# <a name="step-3"></a>Step-3 - Batch rename 
Now all your usb key contain a system ready to run on raspberry. But they **all have the same name**.
We want to be able to distinguish them and thus use custom domain hostname when they are on the same network.

## Operation a: label them if you didn't do it before
Check that each of your key got a physical number. If not label it.

## Operation b: plug them to the hub in ascending order
Then plug them one by one in ascending order to your usb hubs. From `01` to `02`.
This is a very **critical operation**. You do not want to mess the numbering of your usb keys. You can not undo it. If you miss you'll have to rename one by one.

Each time you plug a key in, make sure that the partition is auto mounted using `$ df -h`. 
If it does not show up, manually mount it.

## Operation c: edit the batch-rename.sh script
Once you're done, edit the `batch-rename.sh` script to fit your needs.
Write the hostname of your primary key, the new hostname you want, the first number inserted and the last one.

Then simply run:
```
bash batch-rename.sh
```
It should take 1 sec. And you're done.

Plug the usb keys to the raspberry pi's and check them on the network.