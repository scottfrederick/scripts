#!/bin/bash

if [[ "$OSTYPE" == "linux"* ]]; then
  sudo apt-get update
  sudo apt-get install build-essential curl file git
fi

echo "Cloning scripts"
git clone https://github.com/scottfrederick/scripts .scripts


echo "Cloning dotfiles"
git clone https://github.com/scottfrederick/dotfile .dotfiles


echo "Installing homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


echo "Installing sdkman"
curl -s "https://get.sdkman.io" | bash


echo "Installing docker"
/bin/bash -c "$(curl -fsSL https://get.docker.com -o get-docker.sh)"
