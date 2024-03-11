#!/bin/bash

function sdkj() {
  if [ "$1" == "" ]; then
    echo "Expected Version prefix"
    exit 1
  fi
  PREFIX=$1
  CONTAINS=$2
  CANDIDATES=$(ls ~/.sdkman/candidates/java/)
  CANDIDATE=
  for v in $CANDIDATES; do
    if [[ "$v" == *"${PREFIX}."* ]]; then
      if [ "$CONTAINS" != "" ]; then
          if [[ "$v" == *"${CONTAINS}"* ]]; then
            CANDIDATE="$v"
          fi
      else
        CANDIDATE="$v"
      fi
    fi
  done
  if [ "$CANDIDATE" != "" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk use java $CANDIDATE
  else
    echo "Couldn't find an installed distribution for $@"    
  fi
}

if [ "$1" != "" ]; then
  sdkj $@
fi

