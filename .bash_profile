#!/bin/bash

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

if [ -f ~/.aliases ]; then
   source ~/.aliases
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
