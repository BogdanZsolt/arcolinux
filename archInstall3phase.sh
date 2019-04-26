#!/bin/bash
set -e
echo [multilib] >> /etc/pacman.conf
echo include = /etc/pacman.d/mirrorlist >> /etc/pacman.conf
pacman -Suy
pacman -S bash-completion
useradd -m -g users -G audio,video,network,wheel,storage -s /bin/bash shiru
passwd shiru
EDITOR=nano visudo
