#!/bin/bash

sudo swapoff /swapfile
sudo dd if=/dev/zero of=/swapfile count=4 bs=1G
sudo mkswap /swapfile
sudo chmod 0600 /swapfile
sudo swapon /swapfile
swapon --show
