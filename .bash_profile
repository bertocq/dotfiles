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

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

#export CC=gcc-4.2

#add Homebrew’s sbin to PATH
export PATH=/usr/local/sbin:$PATH

# test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
