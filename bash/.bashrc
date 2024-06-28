#!/usr/bin/env bash

source ~/dotfiles/bash/shell
source ~/dotfiles/bash/prompt
source ~/dotfiles/bash/aliases
source ~/dotfiles/bash/functions
source ~/dotfiles/bash/system
source ~/dotfiles/bash/apps

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
