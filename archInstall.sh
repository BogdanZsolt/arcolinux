#!/bin/bash
set -e

ping -c 3 archlinux.org
efivar -l
loadkeys hu
timedatectl set-ntp true
wipefs -a /dev/sda
parted /dev/sda mklabel gpt
sgdisk /dev/sda -n=1:0:+512M -t=1:ef00
sgdisk /dev/sda -n=2:0:+30G -t=2:8300
sgdisk /dev/sda -n=3:0:0
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda3
mount /dev/sda2 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/sda3 /mnt/home
nano /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel
genfstab -U /mnt >> /mnt/etc/fstab
#arch-chroot /mnt
ln -sf /mnt/usr/share/zoneinfo/Europe/Budapest /mnt/etc/localtime
hwclock --systohc
cat << EOF >> /mnt/etc/locale.gen

hu_HU.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOF
locale-gen
cat << EOF > /mnt/etc/locale.conf
LANG=en_US.UTF-8
LC_COLLATE=hu_HU.UTF-8
LC_ADDRESS=hu_HU.UTF-8
LC_IDENTIFICATION=hu_HU.UTF-8
LC_MAESUREMENT=hu_HU.UTF-8
LC_MONETARY=hu_HU.UTF-8
LC_NAME=hu_HU.UTF-8
LC_NUMERIC=hu_HU.UTF-8
LC_PAPER=hu_HU.UTF-8
LC_TELEPHONE=hu_HU.UTF-8
LC_TIME=hu_HU.UTF-8
EOF
echo KEYMAP=hu > /mnt/etc/vconsole.conf
echo LucykaNotebook02 > /mnt/etc/hostname
cat << EOF >> /mnt/etc/hosts
127.0.0.1 localhost
::1     localhost
127.0.0.1 LucykaNotebook02.localdomain LucykaNotebook02
EOF
pacstrap /mnt networkmanager
systemctl enable NetworkManager
nano /mnt/etc/mkinitcpio.conf
passwd
pacstrap /mnt grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --recheck
grub-mkconfig -o /boot/grub/grub.cfg