#!/bin/env bash

echo '------------------------------------------------------------------------'
echo 'show disks before the change'
echo '------------------------------------------------------------------------'
sudo lsblk
echo ''
sudo df -h
echo ''

echo '------------------------------------------------------------------------'
echo 'create partitions on available AWS EBS disks'
echo '------------------------------------------------------------------------'
sudo parted /dev/xvdb mklabel gpt mkpart primary ext4 0% 100%
echo ''
sudo parted /dev/xvdc mklabel gpt mkpart primary ext4 0% 100%
echo ''
sudo parted /dev/xvdd mklabel gpt mkpart primary ext4 0% 100%
echo ''

echo '------------------------------------------------------------------------'
echo 'install LVM2'
echo '------------------------------------------------------------------------'
sudo yum install lvm2 -y
echo ''

echo '------------------------------------------------------------------------'
echo 'register 2 out of 3 EBS disks with LVM'
echo '------------------------------------------------------------------------'
sudo pvcreate /dev/xvdb1 /dev/xvdc1
echo ''

echo '------------------------------------------------------------------------'
echo 'create LVM volume group'
echo '------------------------------------------------------------------------'
sudo vgcreate vg01 /dev/xvdb1 /dev/xvdc1
echo ''

echo '------------------------------------------------------------------------'
echo 'create LVM logical volume'
echo '------------------------------------------------------------------------'
sudo lvcreate -L 5G -n vol01 vg01
echo ''

echo '------------------------------------------------------------------------'
echo 'create filesystem on the logical volume'
echo '------------------------------------------------------------------------'
sudo mkfs.ext4 /dev/vg01/vol01
echo ''

echo '------------------------------------------------------------------------'
echo 'mount LVM logical volume to /data01'
echo '------------------------------------------------------------------------'
sudo mkdir /data01
echo ''
sudo mount /dev/vg01/vol01 /data01
echo ''

echo '------------------------------------------------------------------------'
echo 'verify volume /data01'
echo '------------------------------------------------------------------------'
sudo df -h /data01
echo ''

echo '------------------------------------------------------------------------'
echo 'extend logical volume with extra space from 3rd EBS disk'
echo '------------------------------------------------------------------------'
sudo pvcreate /dev/xvdd1
echo ''

echo '------------------------------------------------------------------------'
echo 'add another 3rd PV to the VG'
echo '------------------------------------------------------------------------'
sudo vgextend vg01 /dev/xvdd1
echo ''

echo '------------------------------------------------------------------------'
echo 'allocate all remaining disk space from the volume group to the logical volume'
echo '------------------------------------------------------------------------'
sudo lvextend -l +100%FREE /dev/vg01/vol01
echo ''

echo '------------------------------------------------------------------------'
echo 'perform online resizing of the logical volume'
echo '------------------------------------------------------------------------'
sudo resize2fs /dev/vg01/vol01
echo ''

echo '------------------------------------------------------------------------'
echo 'show disks after the change'
echo '------------------------------------------------------------------------'
sudo lsblk
echo ''
sudo df -h
