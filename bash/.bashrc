#!/usr/bin/env bash

source ~/dotfiles/bash/shell
source ~/dotfiles/bash/prompt
source ~/dotfiles/bash/aliases
source ~/dotfiles/bash/functions
source ~/dotfiles/bash/system
source ~/dotfiles/bash/apps

if [[ -d ~/bin ]]; then
  export PATH=~/bin:$PATH
fi
