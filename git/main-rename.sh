#!bash

set -euo pipefail

git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
