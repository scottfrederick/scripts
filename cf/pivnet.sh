#!/bin/bash
 
set -e
if [ "$PIVNET_TOKEN" == "" ]; then 
  echo "export PIVNET_TOKEN before running this script"
  exit 1
fi

if [ "$#" -ne 2 ]; then
  echo "usage: $0 filename url"  
  exit 1
fi

wget -O "$1" --post-data="" --header="Authorization: Token $PIVNET_TOKEN" $2
 
