#!/bin/bash

echo ""
echo "Installing git-credential-manager"

wget "https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.632/gcmcore-linux_amd64.2.0.632.34631.deb" -O gcmcore.deb
wget "https://github.com/microsoft/Git-Credential-Manager-Core/releases/download/v2.0.498/gcmcore-linux_amd64.2.0.498.54650.deb" -O /tmp/gcmcore.deb
sudo dpkg -i gcmcore.deb
git-credential-manager-core configure

