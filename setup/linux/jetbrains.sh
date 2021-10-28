#!/bin/bash

set -e

echo ""
echo "Installing JetBrains Toolbox"

wget --show-progress -qO ./toolbox.tar.gz "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"

TOOLBOX_TEMP_DIR=$(mktemp -d)

tar -C "$TOOLBOX_TEMP_DIR" -xf toolbox.tar.gz
rm ./toolbox.tar.gz

"$TOOLBOX_TEMP_DIR"/*/jetbrains-toolbox

rm -r "$TOOLBOX_TEMP_DIR"
