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
export PROMPT_SYNCED_SYMBOL=" 👌"
export PROMPT_DIRTY_SYNCED_SYMBOL=" ✏️"
export PROMPT_UNPUSHED_SYMBOL=" ☝️"
export PROMPT_DIRTY_UNPUSHED_SYMBOL=" 🚀"
export PROMPT_UNPULLED_SYMBOL=" 👇"
export PROMPT_DIRTY_UNPULLED_SYMBOL=" 📥"
export PROMPT_UNPUSHED_UNPULLED_SYMBOL=" ↕️"
export PROMPT_DIRTY_UNPUSHED_UNPULLED_SYMBOL=" 💩"

# Add git completion
# https://github.com/git/git/blob/master/contrib/completion/git-completion.bash
source ~/git-completion.bash
complete -o default -o nospace -F _git g

### create directory and cd into it
mkcd () {
  mkdir "$1"
  cd "$1"
}

# Avoid duplicates in bash history & increase history memory & file sizes
HISTSIZE=10000
HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups

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

# Colored man pages
# Source: https://github.com/arturoherrero/dotfiles/blob/master/system/environment.sh
man() {
  env \
  LESS_TERMCAP_mb=$'\E[01;31m' \
  LESS_TERMCAP_md=$'\E[01;38;5;208m' \
  LESS_TERMCAP_me=$'\E[0m' \
  LESS_TERMCAP_se=$'\E[0m' \
  LESS_TERMCAP_ue=$'\E[0m' \
  LESS_TERMCAP_us=$'\E[04;38;5;111m' \
  man "$@"
}
