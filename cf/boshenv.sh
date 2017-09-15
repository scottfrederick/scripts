#!/bin/bash

function boshenv() {
    if [ "$1" = "" ]; then
        /usr/local/bin/bosh envs
    else
        export BOSH_ENVIRONMENT="$1"
    fi
    echo "Current environment is [$BOSH_ENVIRONMENT]"
}
