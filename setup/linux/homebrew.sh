#!/bin/bash

echo ""
echo "Installing homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "Installing homebrew bundle"
brew bundle --file $HOME/.dotfiles/Brewfile
