#!/bin/bash
set -e
cat << EOF >> /etc/pacman.conf
echo [multilib]
echo Include = /etc/pacman.d/mirrorlist
EOF
pacman -Suy
pacman -S bash-completion
useradd -m -g users -G audio,video,network,wheel,storage -s /bin/bash shiru
passwd shiru
EDITOR=nano visudo
