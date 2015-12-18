#!/usr/bin/env bash

## pptx2pdf.sh -- convert pptx to pdf in batch

# Usage: pptx2pdf <PATH>
# Input: path to the folder containing pptx files, default .
# Ouput： pdf files with the same name

# author: Tagerill Wong<buaaben@163.com>
# date: 2015/12/18

# Implementation
# step 1: pptx -> odt via libreoffice
# step 2: odt -> pdf

# TODOs
# - [x] add support for ppt

path=$1

for file in `ls $path`
do
    extension=${file##*\.}
    if [ "$extension" == "pptx" ] || [ "$extension" == "ppt" ] # file files
       then
           name=${file%\.*}
           # convert ppt/pptx to odt file
           libreoffice --headless --convert-to odt --outdir .  $path"/"$file
           odt_file=${name}.odt
           # convert odt to pdf. better than converting ppt/pptx to pdf directly
           unoconv -f pdf $odt_file
           # clear
           rm $odt_file
    fi
done

exit 0
