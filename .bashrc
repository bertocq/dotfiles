#!/bin/bash
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

export EDITOR="subl -w"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Git-radar https://github.com/michaeldfallen/git-radar
export PS1="$PS1\$(git-radar --bash --fetch): "

### Used to change terminal tab title
function title {
    echo -ne "\033]0;"$*"\007"
}
