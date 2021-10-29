#!/bin/bash

echo ""
echo "Installing Zoom"

wget https://zoom.us/client/latest/zoom_amd64.deb
sudo apt install ./zoom_amd64.deb
rm ./zoom_amd64.deb
