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
touch .projectile README.md ChangeLog.org

echo "* $time" >> ChangeLog.org
echo >> ChangeLog.org
echo "+ Init $proj" >> ChangeLog.org

echo "# REAMDE for $proj" >> README.md
echo "author: $author" >> README.md
