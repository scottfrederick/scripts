#!/bin/bash

echo ""
echo "Installing homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing homebrew bundle"
brew bundle --file .dotfiles/Brewfile
