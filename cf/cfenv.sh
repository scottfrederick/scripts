#!/bin/bash

function cfenv() {
    function curenv() {
        if [ "$1" = "" ]; then
            CURENV="default"
        else
            CURENV="$(echo "$1" | cut -d '-' -f 2)"
        fi
    }

    function listenvs() {
        echo "Available environments:"
        for folder in $HOME/.cf*; do
            environment=$(echo "$folder" | cut -d '-' -f 2)
            if [ "$environment" = "$HOME/.cf" ]; then
                environment="default"
            fi
            echo "    $environment   ($folder)"
        done
    }

    function setenv() {
        if [ "$1" = "default" ]; then
            unset CF_HOME
        else
            [[ -d "$HOME/.cf-$1" ]] || mkdir "$HOME/.cf-$1"
            export CF_HOME="$HOME/.cf-$1"
        fi
   }

    if [ "$1" = "" ]; then
        listenvs
    else
        setenv "$1"
    fi
    curenv "$CF_HOME"
    echo "Current environment is [$CURENV]"
}
