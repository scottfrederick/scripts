#!/bin/bash

set -e

echo "Updating Linux"
sudo apt update
sudo apt full-upgrade -y
sudo apt install build-essential apt-transport-https curl file

echo ""
echo "Installing zsh"
sudo apt install zsh
chsh --shell /usr/bin/zsh

echo ""
echo "Installing git"
sudo apt install git

echo ""
echo "Installing vim"
sudo apt install vim

if [ ! -d .scripts ]; then
  echo ""
  echo "Cloning scripts"
  git clone https://github.com/scottfrederick/scripts .scripts
fi

if [ ! -d .dotfiles ]; then
  echo ""
  echo "Cloning dotfiles"
  git clone https://github.com/scottfrederick/dotfiles .dotfiles
  cd .dotfiles
  ./setup-symlinks.sh
  cd -
fi

if [ ! -d ${HOME}/.oh-my-zsh ]; then
  echo ""
  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  mkdir -p $HOME/.dotfiles/zsh/custom/plugins
  git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.dotfiles/zsh/custom/plugins/zsh-autosuggestions
fi

echo ""
echo "Start a new shell"

