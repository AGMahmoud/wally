#!/usr/bin/env bash

# Function: Merge PDF files with outlines
# Input:
#       1. PATH: path that contains PDF files which should be name like "1.2 Test Tile"
# Output: generate a merged PDF file with outline

# Input check
if [ $# -lt 1 ] || [ $# -gt 2 ]
then
    echo "Error: wrong number of arguments"
    echo "Usage: merger_pdf_with_outline.sh path"
    exit
fi

path=$1
cd $path

# Replace whiteblank in the filename with _, This should not be considered here.

# return number of pages of a PDF file
pdf_pages(){
    file=$1
    extension=${file##*\.}
    if [ "$extension" == "pdf" ]
    then
        pdf_info=$(pdfinfo ./$file | grep Pages)
        num=${pdf_info##*\ }
        echo $num
    fi

}

# Generate outline
declare -i page=1               # Page
declare -i level=1              # Current headline lever
touch outline
for file in `ls . | grep '^[0-9]*\.[0-9]'_.*\.pdf`
do
    chapter=${file%%_*}
    if [ ${chapter##*\.} == 0 ]
    then
        level=1
    else
        level=2
    fi
    headline=${file#*_}
    echo "$level $page $chapter $headline" >> outline
    page_num=$(pdf_pages $file)
    page=$((page+page_num))
done


# merge using gs
gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=out.pdf  *.pdf

# generate outline for the merged PDF file
pdfoutline out.pdf outline output.pdf
