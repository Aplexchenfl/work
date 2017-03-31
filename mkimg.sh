#!/bin/sh

sudo rm aplex.img -rf
sync
sudo dd if=/dev/zero of=aplex.img bs=1M count=200

sudo losetup -f --show aplex.img

sudo fdisk /dev/loop0 << EOF
o
n
p
1

+10M
n
p
2


t
1
e
a
1
w
EOF

sudo kpartx -av /dev/loop0
sleep 2
sudo mkfs.vfat -F 16  /dev/mapper/loop0p1
sleep 2
sudo mkfs.ext4  /dev/mapper/loop0p2
sleep 2
echo "a. Partitioning the aplex.img over..\n"

sudo mount /dev/mapper/loop0p1  ~/mnt
cd ~/image
sudo cp u-boot.img zImage MLO am335x-sbc7109.dtb  ~/mnt -rf
sudo cp uEnv_emmc.txt   ~/mnt/uEnv.txt  -rf
sync
sudo umount ~/mnt
sync
echo "b. Copy u-boot to partition 1 over ...\n"

sudo mount /dev/mapper/loop0p2  ~/mnt
sudo cp /home/aplex/aplex/filesystem/rootfs/*  ~/mnt -arf
sudo rm ~/mnt/autoburn.sh -rf
sync
cd ~
sleep 3
sudo umount ~/mnt
echo "c. Copy rootfs to partition 2 over ...\n"

sudo kpartx -d /dev/loop0
sudo losetup -d /dev/loop0
sync
