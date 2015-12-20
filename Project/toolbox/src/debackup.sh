#! /usr/bin/env bash

# debackup.sh  --- remove backup files recursively in given folders


# input check
argc=$#
if [ $argc -eq 0 ]              # check if any path is specified
then
    path="."
    echo "Warning: no given path, using current workspace..."
else
    path=$@
    for p in $path              # check if given paths are effective
    do
        if ! [ -d $p ]
        then
            echo "Wrong arguments: arguments should be a directrory"
            exit -1
        fi
    done
fi


# @function: debackup
# @brief: recusively remove files ended with ~ in given dir
# @param: path
function debackup(){
    path=$1
    cd $path
    for f in $(ls . | grep -E '*~$')
    do
        if rm $f
        then
            echo "$f is deleted"
        fi
    done

    for p in $(ls .)
    do
        if [ -d $p ]
        then
            debackup $p
        fi
    done
}


# main
for p in $path
do
    debackup $p
done
