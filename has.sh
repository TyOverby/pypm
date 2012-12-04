#!/bin/bash

source config.sh

SYS_CACHE="$USER_CONF/system_installed.txt"
CUS_CACHE="$USER_CONF/custom_installed.txt"

# Checks to see if a package is located inside the cached list of
# software that is already installed.
if [ "$3" == "" ]
then
    cat $SYS_CACHE $CUS_CACHE | egrep `printf '%q' "$1"`
else
    cat $CUS_CACHE | egrep `printf '%q' "$1"`
    exit
fi

# If we didn't find it in the cache, then see if it is somewhere
# else by trying to locate it
if [ $? -ne 0 ]
then
    locate $2
fi

if [ $? -ne 0 ]
then
    echo "fucked up"

    exit 124
fi
exit 0
