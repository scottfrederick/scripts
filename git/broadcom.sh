#!bash

set -euo pipefail

IFS=""
mapfile -t dirlist < <( find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n' )
for dir in ${dirlist[@]}; do
   if [[ -d "${dir}/.git" ]]; then
      echo "configuring ${dir}"
      cd "${dir}"
      git config user.mail scott.frederick@broadcom.com
      cd ..
   else
      echo "ignoring ${dir}"
   fi
done
