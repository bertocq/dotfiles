#!/bin/bash
############################
# install_and_config.sh
# - Creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
# - Updates macos sofware and XCode dev tools
# - Installs Homebrew, Cask, Mas and a list of apps based on Brewfile
# - Installs Ruby along some gems
# - Configs multiple macos default variables
# - Ask confirmation to config  Divvy shortcuts
############################

# list files that should be symlinked
files=".aliases .bash_profile .bash_prompt .bashrc .editorconfig .gitattributes .gitconfig .gitignore_global
.gitmessage .rubocop.yml Brewfile com.googlecode.iterm2.plist"

# create symlinks on ~/ for each file
for file in $files; do
  echo "Creating symlink to $file in home directory."
  rm ~/"$file"
  ln -s ~/dotfiles/"$file" ~/"$file"
done

# Get latest version of git-completion script for bash
wget https://raw.github.com/git/git/master/contrib/completion/git-completion.bash -O ~/git-completion.bash

# Update firmware
sudo softwareupdate -ia

# XCode dev tools install
xcode-select --install

# Install Homebrew and use Brewfile with Cask and Mas
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew tap Homebrew/bundle # https://github.com/Homebrew/homebrew-bundle
brew bundle install
brew bundle check # Check everything anything to install/upgrade
brew cask cleanup # Delete cask downloads

# Install Ruby + Bundler & Rubocop
rbenv install 2.3.1
rbenv global 2.3.1
gem install bundler
gem install rubocop
gem install rubocop-rspec

# Use Sexy Bash Prompt https://github.com/twolfson/sexy-bash-prompt
(cd /tmp && git clone --depth 1 --config core.autocrlf=false https://github.com/twolfson/sexy-bash-prompt && cd sexy-bash-prompt && make install) && source ~/.bashrc

# Bash 4 in OS X
sudo bash -c "echo $(brew --prefix)/bin/bash >> /etc/shells"
chsh -s "$(brew --prefix)"/bin/bash

# Show hidden files on Finder
defaults write com.apple.finder AppleShowAllFiles YES

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable creation of metadata files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable creation of metadata files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Change screenshots format
defaults write com.apple.screencapture type jpg

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show battery life percentage.
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Computer Name
scutil --set ComputerName "bcq"
scutil --set LocalHostName "bcq"
scutil --set HostName "bcq"

# Use own SublimeText config
rm -rf ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
ln -s ~/dotfiles/sublimetext ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

# Divvy shortcuts setup: (will prompt on Safari to confirm)
open -a Safari "$(< ~/dotfiles/.divvy)"
