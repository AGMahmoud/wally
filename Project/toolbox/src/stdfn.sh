#!/usr/bin/env bash

# stdfn.sh  -- standardize filename in a folder
# basically, replace whitespace with underscore

# Author: TigerDWong<buaaben@163.com>
# Date: 2015/12/18
# Version: 0.1

# Usage: bash <PATH>

path=$1
cd "$path"
find .| while read i;
do
    j=`echo $i|tr -s ' ' '_'`
    if test "$i" != "$j"
        then
            mv "$i" "$j"
    fi
done
