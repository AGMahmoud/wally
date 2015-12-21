#!/usr/bin/env  bash

# create a new project with a given name

# input check
if ! [ $# -eq 1 ]
then
    echo "Wrong number of argument"
    echo "Usage: project.sh <PROJ>"
    exit -1
fi

proj=$1			     # project name
ws=~/Wally/Project/	     # workspace where all projects are nested
author="Tigerill Wong <buaaben@163.com>"
time=$(date +%Y/%m/%d)

cd $ws

mkdir $proj
cd $proj
mkdir test
touch .projectile README.md ChangeLog.txt

echo "# $time" >> ChangeLog.txt
echo >> ChangeLog.txt
echo "* Init $proj" >> ChangeLog.txt

echo "# REAMDE for $proj" >> README.md
echo "author: $author" >> README.md
