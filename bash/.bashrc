#!/usr/bin/env bash

if [ -f ~/.aliases ]; then
   source ~/.aliases
fi

if [[ -d ~/bin ]]; then
  export PATH=~/bin:$PATH
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

eval "$(rbenv init -)"

# English as default
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

# Set XDG dirs
export XDG_DATA_HOME=$HOME"/.local/share"
export XDG_CONFIG_HOME=$HOME"/.config"
export XDG_CACHE_HOME=$HOME"/.cache"

# Avoid curl issues
export PATH="/usr/local/opt/curl/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"

# Add Homebrew’s sbin to PATH
export PATH=/usr/local/sbin:$PATH

# Set bash colors
export CLICOLOR=1
export LS_COLORS='di=32:ln=36:ex=31:or=37;41'

# Avoid duplicates in bash history & increase history memory & file sizes
HISTSIZE=10000
HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups

# Customize bash behaviour
shopt -s autocd # type directory name to cd into it
shopt -s cdspell # correct directory name spelling errors
shopt -s checkwinsize # adjust lines & columns after each command
shopt -s cmdhist # store multi-line commands in single history entry
shopt -s histappend # append to the history file instead of overwriting

# Config sublimetext as default editor
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export EDITOR="subl -w"

# Overwrite macos old sqlite3
export PATH="/usr/local/opt/sqlite/bin:$PATH"

# Silence macos zsh promotion
export BASH_SILENCE_DEPRECATION_WARNING=1

# Run twolfson/sexy-bash-prompt
## https://github.com/twolfson/sexy-bash-prompt
export PROMPT_SYNCED_SYMBOL=" 👌"
export PROMPT_DIRTY_SYNCED_SYMBOL=" ✍️"
export PROMPT_UNPUSHED_SYMBOL=" 👆"
export PROMPT_DIRTY_UNPUSHED_SYMBOL=" 🖕"
export PROMPT_UNPULLED_SYMBOL=" 👇"
export PROMPT_DIRTY_UNPULLED_SYMBOL=" 👎"
export PROMPT_UNPUSHED_UNPULLED_SYMBOL=" ↕️"
export PROMPT_DIRTY_UNPUSHED_UNPULLED_SYMBOL=" 💩"
. ~/.bash_prompt

# Add Git-radar to prompt
## https://github.com/michaeldfallen/git-radar
export PS1="$PS1\$(git-radar --bash --fetch): "

### create directory and cd into it
mkcd () {
  mkdir "$1"
  cd "$1"
}

function title {
    echo -ne "\033]0;"$*"\007"
}

# Print directories size
# Source: https://diamantidis.github.io/2020/01/04/find-large-files-from-command-line
dirsize() {
  du -ah "$1" | sort -rh | head -n 20
}

# export NVM_DIR="$HOME/.nvm"
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
# [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

