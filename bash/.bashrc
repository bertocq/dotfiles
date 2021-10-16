#!/usr/bin/env bash

# shellcheck source=/Users/bertocq/dotfiles/bash/shell
source ~/dotfiles/bash/shell
# shellcheck source=/Users/bertocq/dotfiles/bash/prompt
source ~/dotfiles/bash/prompt
# shellcheck source=/Users/bertocq/dotfiles/bash/aliases
source ~/dotfiles/bash/aliases
# shellcheck source=/Users/bertocq/dotfiles/bash/functions
source ~/dotfiles/bash/functions
# shellcheck source=/Users/bertocq/dotfiles/bash/system
source ~/dotfiles/bash/system
# shellcheck source=/Users/bertocq/dotfiles/bash/apps
source ~/dotfiles/bash/apps

if [[ -d ~/bin ]]; then
  export PATH=~/bin:$PATH
fi
