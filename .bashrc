#!/bin/bash

if [ -f ~/.aliases ]; then
   source ~/.aliases
fi

if [[ -d ~/bin ]]; then
  export PATH=~/bin:$PATH
fi

eval "$(rbenv init -)"
eval "$(hub alias -s)"

export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"

# Add Homebrew’s sbin to PATH
export PATH=/usr/local/sbin:$PATH

# Just in case https://github.com/lionheart/openradar-mirror/issues/15361 keeps being an issue
# { eval `ssh-agent`; ssh-add -A; } &>/dev/null

if brew command command-not-found-init > /dev/null 2>&1; then eval "$(brew command-not-found-init)"; fi

# set bash colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Run twolfson/sexy-bash-prompt
. ~/.bash_prompt

# Add git completion
# https://github.com/git/git/blob/master/contrib/completion/git-completion.bash
source ~/git-completion.bash
complete -o default -o nospace -F _git g

### create directory and cd into it
mkcd () {
  mkdir "$1"
  cd "$1"
}

# Avoid duplicates in bash history, share between terminals & increase history memory & file sizes
# https://unix.stackexchange.com/a/18443
HISTSIZE=10000
HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"

export EDITOR="subl -w"
export GIT_EDITOR="subl -w"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Git-radar https://github.com/michaeldfallen/git-radar
export PS1="$PS1\$(git-radar --bash --fetch): "

### Used to change terminal tab title
function title {
    echo -ne "\033]0;"$*"\007"
}
