#!/bin/bash
############################
# .makesymlinks.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

dir=~/dotfiles
# get all files, excluding DS_STORE, README and this file
files="$(ls -A $dir | grep -vE 'DS|README|makesymlinks')"

# create symlinks on ~/ for each dotfile
for file in $files; do
  echo "Creating symlink to $file in home directory."
  ln -s $dir/$file ~/$file
done
