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
cat << EOF > /mnt/root/archIntallPhase2.sh
#!/bin/bash
set -e
locale-gen
systemctl enable NetworkManager
sudo pacman -S network-manager-applet xfce4-notifyd
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
echo "**********************************************************************"
echo "**                                                                  **"
echo "**  Next, unmount all mounted partitions and reboot the system:     **"
echo "**  exit                                                            **"
echo "**  umount -R /mnt                                                  **"
echo "**  reboot                                                          **"
echo "**                                                                  **"
echo "**********************************************************************"
rm /home/archIntallPhase2.sh
EOF
chmod 766 /mnt/root/archIntallphase2.sh
cat << EOF > /mnt/root/archInstallPhase3.sh
#!/bin/bash
set -e
echo [multilib] >> /etc/pacman.conf
echo Include = /etc/pacman.d/mirrorlist >> /etc/pacman.conf
pacman -Suy
pacman -S bash-completion
useradd -m -g users -G audio,video,network,wheel,storage -s /bin/bash shiru
passwd shiru
EDITOR=nano visudo
pacman -S git --noconfirm
mkdir /home/shiru/temp
echo #!/bin/bash > /home/shiru/temp/archInstallPhase4.sh
echo set -e >> /home/shiru/temp/archInstallPhase4.sh
echo >> /home/shiru/temp/archInstallPhase4.sh
echo git clone https://github.com/arcolinuxd/arco-qtile /home/shiru/temp/arco-qtile >> /home/shiru/temp/archInstallPhase4.sh
echo git clone https://aur.archlinux.org/trizen.git >> /home/shiru/temp/archInstallPhase4.sh
echo cd trizen >> /home/shiru/temp/archInstallPhase4.sh
echo makepkg -si >> /home/shiru/temp/archInstallPhase4.sh
echo trizen -Suyy >> /home/shiru/temp/archInstallPhase4.sh
echo trizen -S yay >> /home/shiru/temp/archInstallPhase4.sh
echo sudo pacman -S xorg-server xorg-apps xorg-xinit xterm >> /home/shiru/temp/archInstallPhase4.sh
echo sudo pacman -S xf86-video-intel >> /home/shiru/temp/archInstallPhase4.sh
echo Section "InputClass" > /etc/X11/xorg.conf.d/00-keyboard.conf
echo        Identifier "system-keyboard" >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo        MatchIsKeyboard "on" >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo        Option "XkbLayout" "hu" >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo        Option "XkbModel" "latitude" >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo EndSection >> /etc/X11/xorg.conf.d/00-keyboard.conf
chown shiru home/shiru/temp/archInstallPhase4.sh
chmod 777 home/shiru/temp/archInstallPhase4.sh
echo 
echo ***************************************************************************************
echo *                                                                                     *
echo *  logout from root user & login your user account. Runing archInstallPase4.sh script *
echo *  in your temp directory ~/temp.                                                     *
echo *                                                                                     *
echo ***************************************************************************************
EOF
chmod 766 /mnt/root/archInstallPhase3.sh
echo 
echo "****************************************************************************************************************************************" 
echo "* Run arch-chroot /mnt. After in the /home directory you can find a scrip archIntall2phase.sh. Run this for continue the Installation. *"
echo "****************************************************************************************************************************************"
exit 0