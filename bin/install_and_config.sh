#!/usr/bin/env bash
############################
# install_and_config.sh
# - Creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
# - Updates macos sofware and XCode dev tools
# - Installs Homebrew, Cask and a list of apps based on Brewfile
# - Installs Ruby along some gems
# - Configs multiple macos default variables
# - Ask confirmation to config  Divvy shortcuts
############################

# Update firmware
sudo softwareupdate -ia

# XCode dev tools install
xcode-select --install

# Allow apps from unidentified developers without macos asking every single time
sudo spctl --master-disable

## Clone repo via HTTPS
git clone https://github.com/bertocq/dotfiles.git ~/dotfiles && cd ~/dotfiles

## Bash
ln -s ~/dotfiles/bash/.aliases ~/.aliases
ln -sf ~/dotfiles/bash/.bash_profile ~/.bash_profile
ln -s ~/dotfiles/bash/.bash_prompt ~/.bash_prompt
ln -sf ~/dotfiles/bash/.bashrc ~/.bashrc
ln -s ~/dotfiles/bin ~/bin

## Tools
ln -s ~/dotfiles/tools/.editorconfig ~/.editorconfig
ln -s ~/dotfiles/tools/.unused.yml ~/.unused.yml
ln -s ~/dotfiles/tools/Brewfile ~/Brewfile
ln -s ~/dotfiles/tools/Brewfile.lock.json ~/Brewfile.lock.json
ln -s ~/dotfiles/tools/com.googlecode.iterm2.plist ~/com.googlecode.iterm2.plist
ln -s ~/dotfiles/sublimetext/.SideBarEnhancements.optout ~/.SideBarEnhancements.optout
mkdir ~/.config/translate-shell/
ln -s ~/dotfiles/tools/translate-shell/init.trans ~/.config/translate-shell/init.trans
ln -s ~/dotfiles/tools/translate-shell/theme.trans ~/.config/translate-shell/theme.trans

## Ruby
ln -s ~/dotfiles/ruby/.gemrc ~/.gemrc
ln -s ~/dotfiles/ruby/.ruby-version ~/.ruby-version
ln -s ~/dotfiles/ruby/.rubocop.yml ~/.rubocop.yml
ln -s ~/dotfiles/ruby/.pryrc ~/.pryrc
ln -s ~/dotfiles/ruby/.irbrc ~/.irbrc

## Git
ln -s ~/dotfiles/git/.git_template ~/.git_template
ln -s ~/dotfiles/git/.gitattributes ~/.gitattributes
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/git/.gitignore_global ~/.gitignore_global
ln -s ~/dotfiles/git/.github_template.md ~/.github_template.md
# Get latest version of git-completion script for bash
curl -L https://raw.github.com/git/git/master/contrib/completion/git-completion.bash > ~/dotfiles/git/.git-completion.bash
ln -s ~/dotfiles/git/.git-completion.bash ~/.git-completion.bash
curl -L https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh > ~/dotfiles/git/.git-prompt.sh
ln -s ~/dotfiles/git/.git-prompt.sh ~/.git-prompt.sh
ln -s ~/.git/hooks ~/dotfiles/git/hooks

# Install Homebrew and use Brewfile with Cask
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew tap Homebrew/bundle # https://github.com/Homebrew/homebrew-bundle
brew bundle install
brew bundle check # Check everything anything to install/upgrade
brew cleanup # Delete cask downloads

# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install

# Install Ruby + Bundler & Rubocop
rbenv install 2.4.1
rbenv global 2.4.1
gem install bundler
gem install rubocop
gem install rubocop-rspec

ln -sf ~/dotfiles/ruby/.bundle/config ~/.bundle/config

mkdir ~/Downloads/music
mkdir ~/Downloads/video
mkdir ~/Downloads/screenshots

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

# Change screenshots destination folder
defaults write com.apple.screencapture location ~/Downloads/screenshots

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

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Show the ~/Library folder
chflags nohidden ~/Library

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Disable Spell Check in Every Application system-wide
defaults write com.apple.notes NSAutomaticSpellingCorrectionEnabled -bool false

# Disable Shadow for Window Screenshots
defaults write com.apple.screencapture disable-shadow -bool TRUE
killall SystemUIServer

# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false

# Always open everything in Finder's list view.
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Disable font smoothing. 0: disable 1: light 2: medium (default) 3: strong
defaults -currentHost write -g AppleFontSmoothing -int 0

# Computer Name
scutil --set ComputerName "bcq"
scutil --set LocalHostName "bcq"
scutil --set HostName "bcq"

# Use own SublimeText config
ln -sf ~/dotfiles/sublimetext ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

# Divvy shortcuts setup: (will prompt on Safari to confirm)
open -a Safari "$(< ~/dotfiles/.divvy)"
