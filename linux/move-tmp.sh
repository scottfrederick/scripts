#!/bin/bash

if [ -d /home/tmp ]; then
  echo "/home/tmp exists"
else 
  sudo mkdir /home/tmp
  sudo chown root:root /home/tmp
  sudo chmod 1777 /home/tmp
fi

if grep -x "^/home/tmp.*" /etc/fstab; then
  echo "/etc/fstab already contains entry for /tmp. No changes made."
else 
  echo "/home/tmp /tmp none defaults,bind 0 0" | sudo tee -a /etc/fstab
  echo "Reboot for fstab changes to take effect"
fi

