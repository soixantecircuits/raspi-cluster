This tutorial explains the steps we use to prepare iso images of our systems, ready to be duplicated on multiple raspberry pi.
It is useful to have some knowledge in linux tools to manipulate partitions and filesystems.
This tutorial will give you a basic knowledge of this tools, throught making the boot SD card and the system usb card.

We use a SD card to boot, and a usb key for the system.
We beliebe in this solution for two reasons:
* SD cards are not meant to be used for long-term multiple read & write operations, usb key are better for this. This means that the SD card can have corrupted data after some time.
* copying 3 GB on 64 SD cards is very long. It's faster to copy the boot partition (63 MB) on 64 SD cards, and then copy the system (3 GB) on 64 usb keys with multiple usb hubs to copy in parallel.

### Requires

`sudo apt-get install pv`

### basics

We are going to use usb and sd partition on your hard drive, beware that you an damage your partition if you write on the wrong disk.
To know what disk to edit run

```
df -h
```

it will list available disks.

In this tutorial we will assume that your SD card is on `/dev/mmcblk0` and your usb key on `/dev/sdb`.
Yours should be different. Take care when copy/pasting.


We will modify two things: partitions and filesystems, two different things. Check the links at the end of the tutorial if you are not familiar with the two concepts.

### Start from sd card

Get a raspbian iso image from the [raspberry pi foundation](https://www.raspberrypi.org/downloads/) , clone it on a sd card using this steps

```
umount /dev/mmcblk0
sudo dd bs=4M  if=/path/to/raspbian.iso | pv | dd of=/dev/mmcblk0
sync
```

Try this sd card on a raspberry pi and make sure it is working as expected.

### Create an image of a boot SD card

Insert back the SD card in your computer.
Edit the boot partition to startup with the usb key instead of partition 2 of SD card, with this line:
```
sed -i 's/root=\/dev\/mmcblk0p2/root=\/dev\/sda1/' /path/to/mounted/p0/boot/cmdline.txt
```

And then create an iso image

```
umount /dev/mmcblk0p1
umount /dev/mmcblk0p2
sudo dd bs=4M count=16 if=/dev/mmcblk0 | pv | dd of=boot.iso
```

### Create a boot SD card

Insert an other SD card and

```
umount /dev/mmcblk0
sudo dd bs=4M  if=boot.iso | pv | dd of=/dev/mmcblk0
sync
```

### Get an image of the filesystem

```
umount /dev/mmcblk0p1
umount /dev/mmcblk0p2
sudo dd bs=4M  if=/dev/mmcblk0 | pv | dd of=snapbox.iso
sync
```

### Reduce p2 partition

Setup the image via loopback

```
sudo losetup -f --show  snapbox.iso
```

Note the loop where it is setup, like `/dev/loop23`


#### Resize filesystem

```
sudo fdisk -l /dev/loop23
```

Result:
```
Disk /dev/loop23: 14,9 GiB, 15931539456 bytes, 31116288 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xce513368

Device        Boot  Start      End  Sectors  Size Id Type
/dev/loop23p1        8192   137215   129024   63M  c W95 FAT32 (LBA)
/dev/loop23p2      137216 31116287 30979072 14,8G 83 Linux

```

Note the start sector of p2 (137216) to setup it

```
sudo losetup -f -o $((137216*512)) --show  snapbox.iso
```
Result: `/dev/loop24`

And mount

```
sudo mkdir /mnt/iso
sudo mount /dev/loop24 /mnt/iso
```

Get the size of partition

```
df
```

Result:
```
Filesystem     1K-blocks      Used Available Use% Mounted on
dev              8147152         0   8147152   0% /dev
run              8150752      1348   8149404   1% /run
/dev/sda6       30832636  25923332   3320056  89% /
tmpfs            8150752    380204   7770548   5% /dev/shm
tmpfs            8150752         0   8150752   0% /sys/fs/cgroup
tmpfs            8150752       360   8150392   1% /tmp
/dev/sda7      113873536 104152548   3913476  97% /home
/dev/sda1         262144     24804    237340  10% /boot/efi
tmpfs            1630148        16   1630132   1% /run/user/120
tmpfs            1630148        28   1630120   1% /run/user/1000
/dev/loop24     15216784   2466812  12102196  17% /mnt/iso
```

Note the total size used (2466812) and add a bit more space you need for runtime execution or additional programs to install later. Here we will use 2700000.

```
sudo umount /dev/loop24
sudo fsck -f /dev/loop24
sudo resize2fs -f /dev/loop24 $((2700000/4))
```

Remount it to make sure everything went fine.
```
sudo mount /dev/loop24 /mnt/iso
ls /mnt/iso
```

#### Rewrite partition

```
sudo fdisk /dev/loop23
```
Press 'd' to delete partition, the '1', then 'd' again to delete the second partition.
Create a new one with 'n', and select primary and partition number 1
First sector, 2048.
Last sector is the total size, by default, it is the last one: 31116287
We will do the math to shrink this in an other window:

```
echo '2700000*2 + 2048' | bc
```

Enter the result back in fdisk
And then, type 'w' to write, ctrl+D to exit

Setup this new partition
```
sudo losetup -f --show -o $(echo "2048*512" | bc) snapbox.iso
```

Copy the content of the old one to this new partition

```
sudo dd if=/dev/loop24 of=/dev/loop25
```

Mount it to make sure everything went fine.
```
sudo mkdir /mnt/iso2
sudo mount /dev/loop25 /mnt/iso2
ls /mnt/iso2
```

### Truncate the iso image

Do the math
```
echo '2700000 + (2048/2)' | bc 
```

And apply

```
truncate -s 2701024K snapbox.iso
```

Mount it to make sure everything went fine.

```
sudo mkdir /mnt/iso3
sudo losetup -f --show -o $(echo "2048*512" | bc) snapbox.iso
sudo mount /dev/loop28 /mnt/iso3
ls /mnt/iso3
```

### Copy to usb key


```
umount /dev/sdb0
sudo dd bs=4M  if=snapbox.iso | pv | dd of=/dev/sdb
sync
```

And then try this usb key with the boot SD card you made earlier.

Voilà!

### Resize later

If you need to expand the filesystem because you lack space, it is easy to do it directly on the raspberrypi. `raspi-config` won't do it because it looks for a SD card. But you can do it this way

```
sudo fdisk /dev/sda 
```
Press 'd' to delete the partition, 'n' to make a new one, primary, number 1, first sector 2048, enter the new size you need for the last sector, default is to expand to the max size on usb key.

Then

```
sudo reboot
sudo resize2fs /dev/sda1
```
Check it did the job: 

```
df -h
```

### Thank you

Helpful links:
http://sirlagz.net/2013/03/04/how-to-resize-partitions-in-an-image-file-part-2/
http://www.cyberciti.biz/tips/understanding-unixlinux-file-system-part-i.html
