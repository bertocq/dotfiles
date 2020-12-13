#!/bin/bash

if [ -f ~/.aliases ]; then
   source ~/.aliases
fi

if [[ -d ~/bin ]]; then
  export PATH=~/bin:$PATH
fi

eval "$(rbenv init -)"

# Add Homebrew’s sbin to PATH
export PATH=/usr/local/sbin:$PATH

# Add command-not-found for Homebrew
## https://github.com/Homebrew/homebrew-command-not-found
if brew command command-not-found-init > /dev/null 2>&1; then eval "$(brew command-not-found-init)"; fi

# Make Homebrew’s completions available in bash
[[ -r "#{etc}/profile.d/bash_completion.sh" ]] && . "#{etc}/profile.d/bash_completion.sh"

# Set bash colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Run twolfson/sexy-bash-prompt
## https://github.com/twolfson/sexy-bash-prompt
. ~/.bash_prompt
export PROMPT_SYNCED_SYMBOL=" 👌"
export PROMPT_DIRTY_SYNCED_SYMBOL=" ✏️"
export PROMPT_UNPUSHED_SYMBOL=" ☝️"
export PROMPT_DIRTY_UNPUSHED_SYMBOL=" 🚀"
export PROMPT_UNPULLED_SYMBOL=" 👇"
export PROMPT_DIRTY_UNPULLED_SYMBOL=" 📥"
export PROMPT_UNPUSHED_UNPULLED_SYMBOL=" ↕️"
export PROMPT_DIRTY_UNPUSHED_UNPULLED_SYMBOL=" 💩"

# Add Git-radar to prompt
## https://github.com/michaeldfallen/git-radar
export PS1="$PS1\$(git-radar --bash --fetch): "

# Add git completion
# https://github.com/git/git/blob/master/contrib/completion/git-completion.bash
source ~/.git-completion.bash
# Complete git commnads when using `g` alias
complete -o default -o nospace -F _git g

# Avoid duplicates in bash history & increase history memory & file sizes
HISTSIZE=10000
HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups

export EDITOR="subl -w"
export GIT_EDITOR="subl -w"

### Used to change terminal tab title
function title {
    echo -ne "\033]0;"$*"\007"
}

### create directory and cd into it
mkcd () {
  mkdir "$1"
  cd "$1"
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

# Print directories size
# Source: https://diamantidis.github.io/2020/01/04/find-large-files-from-command-line
dirsize() {
  du -ah "$1" | sort -rh | head -n 20
}

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Overwrite macos old sqlite3
export PATH="/usr/local/opt/sqlite/bin:$PATH"

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

export TASKNOTE_EDITOR="subl --wait"
export TASKNOTE_FILE_EXT="todo"
export TASKNOTE_FOLDER="~/.tasks/tasknotes"

export XDG_DATA_HOME=$HOME"/.local/share"
export XDG_CONFIG_HOME=$HOME"/.config"
export XDG_CACHE_HOME=$HOME"/.cache"


# heroku autocomplete setup
HEROKU_AC_BASH_SETUP_PATH=/Users/bertocq/Library/Caches/heroku/autocomplete/bash_setup && test -f $HEROKU_AC_BASH_SETUP_PATH && source $HEROKU_AC_BASH_SETUP_PATH;

# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
# source ~/.git-completion.bash
# source ~/.git-prompt.sh
# export GIT_PS1_SHOWDIRTYSTATE="true"
# export GIT_PS1_SHOWSTASHSTATE="true"
# export GIT_PS1_SHOWUNTRACKEDFILES="true"
# export GIT_PS1_SHOWUPSTREAM="auto"
# export PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '


