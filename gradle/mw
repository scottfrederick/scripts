#!/bin/bash

SYSTEM_MVN=/usr/local/bin/mvn

CWD=$PWD
until [ $CWD == / ]; do
    MVNW=$CWD/mvnw
    if [ -e $MVNW ]; then
        exec $MVNW $@
    fi
    CWD=$(dirname $CWD)
done

echo No Maven wrapper found, using $SYSTEM_MVN
exec $SYSTEM_MVN "$@"
