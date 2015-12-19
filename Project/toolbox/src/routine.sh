#! /usr/bin/env bash

# routine.sh
# Do some routines automatically
# 1. git responsity
# 2. email

git_branch="master"		# git branch, default master

ws_list=""

git_push(){
    path=$1			# path need to be absolute
    cd $path
    git add  .	# .gitignore considered to be well configured
    git commit -m "committed automatically by script at $home at `date +%H:%M`"
    git push origin master
}

ws="/home/ben/Wally"		# ~/Wally not working, why?
git_push $ws

# git emacs configures
ws="/home/ben/.emacs.d"
git_push $ws

# git blog
ws="/home/ben/Wally/TagerillWong"
git_push $ws
