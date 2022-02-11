#!/bin/bash

sudo mkdir /home/tmp
chmod 1777 /home/tmp

echo "/home/tmp /tmp none bind 0 0" | sudo tee -a /etc/fstab
