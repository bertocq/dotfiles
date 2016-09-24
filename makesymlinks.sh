#!/bin/bash
############################
# .makesymlinks.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

dir=~/dotfiles
files=".aliases .bash_profile .bash_prompt .bashrc .divvy .iterm_bertocq_profile .rubocop.yml 
.gitconfig .gitignore_global .gitmessage git-completion.bash"

# create symlinks on ~/ for each dotfile
for file in $files; do
  echo "Creating symlink to $file in home directory."
  ln -s $dir/$file ~/$file
done
