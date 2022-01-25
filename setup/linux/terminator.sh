#!/bin/bash

echo ""
echo "Installing Terminator"

sudo add-apt-repository ppa:mattrose/terminator
sudo apt -y update 
sudo apt -y install terminator
