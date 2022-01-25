#!/bin/bash

sudo grub-mkfont /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf \
    --size=36 --output=/boot/grub/fonts/DejaVuSansMono36.pf2 
sudo sh -c 'echo "GRUB_FONT=/boot/grub/fonts/DejaVuSansMono36.pf2" >> /etc/default/grub'
sudo update-grub

