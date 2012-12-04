#!/bin/bash

source config.sh

program_name="$1"
curdir=`pwd`

temp_dir="$USER_CONF/tmp/$program_name"
errors="$USER_CONF/errors"
dest_dir="$USER_ROOT"

mkdir -p $temp_dir

cd $temp_dir

# Determine the processor information used
# Later when extracting the file.
# If this fails, quit the script.
echo "Determining processor architecture..."
uname=`uname -a`
echo $uname | grep x86 > /dev/null
if [ $? -eq 0 ]
then
    proc="x86"
else
    echo $uname | grep i686 > /dev/null
    if [ $? -eq 0 ]
    then
        proc="i686"
    else
        echo "    Unable to determine processor"
        exit 1
    fi
fi
echo "    Processor is $proc"


# Grab the file using yumdownloader
yumdownloader $program_name

# If we got nothing, then quit
if [ $? -ne 0 ]
then
    echo "could not find a file to download" >> $errors
    exit 1
fi

# Try to find the file to extract
file_to_extract=`ls $dirname | grep $program_name | grep -E "($proc)|(noarch)"`
if [ $? -ne 0 ]
then
    # Loosen our search just to the processor type or noarch
    file_to_extract=`ls | grep -E "($proc)|(noarch)"`
    if [ $? -ne 0 ]
    then
        echo "could not find a file to extract" >> $errors
        exit 2
    fi
fi


# Extract the file
cp $file_to_extract $dest_dir
(cd $dest_dir && rpm2cpio $file_to_extract | cpio -idu && rm $file_to_extract)


cd $curdir
echo "$program_name" >> "$USER_CONF/custom_installed.txt"
