#!/bin/bash
set -e

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
mount /dev/sda3 /mnt/home
nano /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel
genfstab -U /mnt >> /mnt/etc/fstab
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
nano /mnt/etc/mkinitcpio.conf
cp arcIntall3phase.sh /mnt/root/arcIntall3phase.sh
cat << EOF > /mnt/home/arcIntall2phase.sh
#!/bin/bash
set -e
locale-gen
systemctl enable NetworkManager
passwd
pacman -S grub efibootmgr
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --recheck
grub-mkconfig -o /boot/grub/grub.cfg
mkdir /boot/efi/EFI/BOOT
cp /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
echo bcfg boot add 1 fs0:\EFI\GRUB\grubx64.efi "My GRUB bootloader" > /boot/efi/startup.nsh
echo exit >> /boot/efi/startup.nsh
echo 
echo Next, unmount all mounted partitions and reboot the system:
echo exit
echo umount -R /mnt
echo reboot
rm /home/arcIntall2phase.sh
EOF
chmod 777 /mnt/home/arcIntall2phase.sh
echo ""
echo "Run arch-chroot /mnt. In the /home directory you can find a scrip arcIntall2phase.sh. Run this for end the Installation."
exit 0