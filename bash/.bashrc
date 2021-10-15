#!/usr/bin/env bash

source ~/dotfiles/bash/aliases
source ~/dotfiles/bash/prompt

[[ -r ~/.fzf.bash ]] && source ~/.fzf.bash;

if [[ -d ~/bin ]]; then
  export PATH=~/bin:$PATH
fi

eval "$(rbenv init -)"

# System
## English as default
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

## Set XDG dirs
export XDG_DATA_HOME=$HOME"/.local/share"
export XDG_CONFIG_HOME=$HOME"/.config"
export XDG_CACHE_HOME=$HOME"/.cache"

## Macos
### Overwrite macos old sqlite3
export PATH="/usr/local/opt/sqlite/bin:$PATH"

### Silence macos zsh promotion
export BASH_SILENCE_DEPRECATION_WARNING=1

# Apps
## Avoid curl issues
export PATH="/usr/local/opt/curl/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"

## Add Homebrew’s sbin to PATH
export PATH=/usr/local/sbin:$PATH

# Config sublimetext as default editor
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export EDITOR="subl -w"

# Bash
## Set bash colors
export CLICOLOR=true
export LS_COLORS='di=32:ln=36:ex=31:or=37;41'

## Avoid duplicates in bash history & increase history memory & file sizes
export HISTSIZE=10000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
# Increase history memory & file sizes
HISTSIZE=100000
HISTFILESIZE=200000
# Following lines do this:
#  - If the same command is entered again consecutively, store only one copy
#  - Save history after every command, so that even if the terminal
#    crashes/force-killed you have saved history. Note that the side-effect of
#    this is that if you execute a command in a terminal, it will be visible in
#    another simultaneously running terminal's history as soon as you execute
#    even one command in the new terminal
#  - If a command is entered which was previously typed in the past (but not
#    consecutively), remove all previous instances from history and add only one
#    new instance, effectively removing all duplicates from history, including
#    non-consecutive ones
shopt -s histappend # append to the history file instead of overwriting
PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"
HISTCONTROL=ignoredups:erasedups

## Customize bash behaviour
shopt -s autocd # type directory name to cd into it
shopt -s cdspell # correct directory name spelling errors
shopt -s checkwinsize # adjust lines & columns after each command
shopt -s cmdhist # store multi-line commands in single history entry

# Colorize man pages with bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Helper functions
## Create directory and cd into it
mkcd() {
  mkdir "$1"
  cd "$1"
}

## Set terminal title
title() {
    echo -ne "\033]0;"$*"\007"
}

## Print directories size
# Source: https://diamantidis.github.io/2020/01/04/find-large-files-from-command-line
dirsize() {
  du -ah "$1" | sort -rh | head -n 20
}
