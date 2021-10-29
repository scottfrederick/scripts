#!/bin/bash

echo "Updating Linux"
sudo apt update
sudo apt full-upgrade -y
sudo apt install build-essential apt-transport-https curl file

echo ""
echo "Installing zsh"
sudo apt install zsh
chsh /bin/zsh

echo ""
echo "Installing git"
sudo apt install git

echo ""
echo "Installing vim"
sudo apt install vim


echo ""
echo "Cloning scripts"
git clone https://github.com/scottfrederick/scripts .scripts


echo ""
echo "Cloning dotfiles"
git clone https://github.com/scottfrederick/dotfiles .dotfiles
cd .dotfiles
./setup-symlinks.#!/bin/sh
cd -
source .zshrc


echo ""
echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


echo ""
echo "Start a new shell"
