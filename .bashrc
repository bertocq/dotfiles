# set bash colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
# Run twolfson/sexy-bash-prompt
. ~/.bash_prompt
# Add git completion
source /usr/local/etc/bash_completion.d/git-completion.bash

### create directory and cd into it
mkcd () {
  mkdir "$1"
  cd "$1"
}

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Git-radar https://github.com/michaeldfallen/git-radar
export PS1="$PS1\$(git-radar --bash --fetch): "

source ~/git-completion.bash

### Used to change terminal tab title
function title {
    echo -ne "\033]0;"$*"\007"
}
