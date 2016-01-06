if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

if [ -f ~/.profile ]; then
   source ~/.profile
fi

if [ -f ~/.aliases ]; then
   source ~/.aliases
fi

eval "$(rbenv init -)"
eval "$(hub alias -s)"

# export NVM_DIR=~/.nvm
# source $(brew --prefix nvm)/nvm.sh

export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"

# export CC=gcc-4.2

# Add Homebrew’s sbin to PATH
export PATH=/usr/local/sbin:$PATH

# test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Just in case https://github.com/lionheart/openradar-mirror/issues/15361 keeps being an issue
# { eval `ssh-agent`; ssh-add -A; } &>/dev/null
