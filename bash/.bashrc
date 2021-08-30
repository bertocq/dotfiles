#!/usr/bin/env bash

if [ -f ~/.aliases ]; then
   source ~/.aliases
fi

if [[ -d ~/bin ]]; then
  export PATH=~/bin:$PATH
fi

eval "$(rbenv init -)"

# Add Homebrew’s sbin to PATH
export PATH=/usr/local/sbin:$PATH

# Set bash colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

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

# Add git completion
# https://github.com/git/git/blob/master/contrib/completion/git-completion.bash
source ~/.git-completion.bash
# Complete git commnads when using `g` alias
complete -o default -o nospace -F _git g

# Avoid duplicates in bash history & increase history memory & file sizes
HISTSIZE=10000
HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups

export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export EDITOR="subl -w"

### create directory and cd into it
mkcd () {
  mkdir "$1"
  cd "$1"
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

export XDG_DATA_HOME=$HOME"/.local/share"
export XDG_CONFIG_HOME=$HOME"/.config"
export XDG_CACHE_HOME=$HOME"/.cache"

# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
# source ~/.git-completion.bash
# source ~/.git-prompt.sh
# export GIT_PS1_SHOWDIRTYSTATE="true"
# export GIT_PS1_SHOWSTASHSTATE="true"
# export GIT_PS1_SHOWUNTRACKEDFILES="true"
# export GIT_PS1_SHOWUPSTREAM="auto"
# export PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '

# export NVM_DIR="$HOME/.nvm"
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
# [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH="/usr/local/opt/curl/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"
