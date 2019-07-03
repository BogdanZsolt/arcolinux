#!/bin/bash
set -e

loadkeys hu
timedatectl set-ntp true
wipefs -a /dev/sda
parted /dev/sda mklabel gpt
sgdisk /dev/sda -n=1:0:+512M -t=1:ef00
sgdisk /dev/sda -n=2:0:+40G -t=2:8300
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
sed -i 's/HOOKS="base udev autodetect modconf block keyboard keymap filesystems fsck"/HOOKS="base udev autodetect modconf block keyboard keymap filesystems fsck shutdown"/' /mnt/etc/mkinitcpio.conf
nano /mnt/etc/mkinitcpio.conf
cat << EOF > /mnt/root/archInstallPhase2.sh
#!/bin/bash
set -e
locale-gen
systemctl enable NetworkManager
pacman -S network-manager-applet xfce4-notifyd --noconfirm
passwd
pacman -S grub efibootmgr --noconfirm
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --recheck
grub-mkconfig -o /boot/grub/grub.cfg
mkdir /boot/efi/EFI/BOOT
cp /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
echo bcfg boot add 1 fs0:\EFI\GRUB\grubx64.efi "My GRUB bootloader" > /boot/efi/startup.nsh
echo exit >> /boot/efi/startup.nsh
echo 
echo "**********************************************************************"
echo "**                                                                  **"
echo "**  Next, unmount all mounted partitions and reboot the system:     **"
echo "**  exit                                                            **"
echo "**  umount -R /mnt                                                  **"
echo "**  reboot                                                          **"
echo "**                                                                  **"
echo "**********************************************************************"
rm /root/archInstallPhase2.sh
EOF
chmod 766 /mnt/root/archInstallPhase2.sh
cat << EOF > /mnt/root/archInstallPhase3.sh
#!/bin/bash
set -e
echo [multilib] >> /etc/pacman.conf
echo Include = /etc/pacman.d/mirrorlist >> /etc/pacman.conf
pacman -Suy
pacman -S bash-completion --noconfirm
useradd -m -g users -G audio,video,network,wheel,storage,rfkill -s /bin/bash shiru
passwd shiru
EDITOR=nano visudo
pacman -S git --noconfirm
mkdir /home/shiru/temp
chown shiru:users /home/shiru/temp
echo "#!/bin/bash" > /home/shiru/temp/archInstallPhase4.sh
echo set -e >> /home/shiru/temp/archInstallPhase4.sh
echo >> /home/shiru/temp/archInstallPhase4.sh
echo git clone https://aur.archlinux.org/trizen.git >> /home/shiru/temp/archInstallPhase4.sh
echo cd trizen >> /home/shiru/temp/archInstallPhase4.sh
echo makepkg -si >> /home/shiru/temp/archInstallPhase4.sh
echo trizen -Suyy >> /home/shiru/temp/archInstallPhase4.sh
echo trizen -S yay --noconfirm >> /home/shiru/temp/archInstallPhase4.sh
echo sudo pacman -S xorg-server xorg-apps xorg-xinit xterm --noconfirm >> /home/shiru/temp/archInstallPhase4.sh
echo sudo pacman -S xf86-video-intel --noconfirm >> /home/shiru/temp/archInstallPhase4.sh
echo sudo mv /home/shiru/temp/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf >> /home/shiru/temp/archInstallPhase4.sh
echo rm -rf /home/shiru/temp/trizen >> /home/shiru/temp/archInstallPhase4.sh 
echo rm /home/shiru/temp/archInstallPhase4.sh >> /home/shiru/temp/archInstallPhase4.sh 
chown shiru /home/shiru/temp/archInstallPhase4.sh
chmod 777 /home/shiru/temp/archInstallPhase4.sh
mv /root/00-keyboard.conf /home/shiru/temp/00-keyboard.conf
echo 
echo "***************************************************************************************"
echo "*                                                                                     *"
echo "*  logout from root user & login your user account. Runing archInstallPase4.sh script *"
echo "*  in your temp directory ~/temp.                                                     *"
echo "*                                                                                     *"
echo "***************************************************************************************"
rm /root/archInstallPhase3.sh
EOF
chmod 766 /mnt/root/archInstallPhase3.sh
cat << EOF > /mnt/root/00-keyboard.conf
Section "InputClass"
       Identifier "system-keyboard"
       MatchIsKeyboard "on" 
       Option "XkbLayout" "hu"
       Option "XkbModel" "latitude"
EndSection
EOF
echo 
echo "****************************************************************************************************************************************" 
echo "* Run arch-chroot /mnt. After in the /home directory you can find a scrip archIntall2phase.sh. Run this for continue the Installation. *"
echo "****************************************************************************************************************************************"
exit 0
