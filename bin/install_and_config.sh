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

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

chsh -s /bin/bash

# Update firmware
sudo softwareupdate -ia

# XCode dev tools install
xcode-select --install

# Install Rosetta 2 for those old apps
sudo softwareupdate --install-rosetta

# Allow apps from unidentified developers without macos asking every single time
sudo spctl --master-disable

## Clone repo via HTTPS
git clone https://github.com/bertocq/dotfiles.git ~/dotfiles && cd ~/dotfiles

## Bash
ln -sf ~/dotfiles/bash/.bash_profile ~/.bash_profile
ln -sf ~/dotfiles/bash/.bashrc ~/.bashrc
touch ~/.hushlogin
ln -s ~/dotfiles/bin ~/bin

## Tools
ln -s ~/dotfiles/tools/.editorconfig ~/.editorconfig
ln -s ~/dotfiles/tools/.unused.yml ~/.unused.yml
ln -s ~/dotfiles/tools/Brewfile ~/Brewfile
ln -s ~/dotfiles/tools/com.googlecode.iterm2.plist ~/com.googlecode.iterm2.plist
ln -s ~/dotfiles/sublimetext/.SideBarEnhancements.optout ~/.SideBarEnhancements.optout
mkdir ~/.config
mkdir ~/.config/translate-shell/
ln -s ~/dotfiles/tools/translate-shell/init.trans ~/.config/translate-shell/init.trans
ln -s ~/dotfiles/tools/translate-shell/theme.trans ~/.config/translate-shell/theme.trans
ln -s ~/dotfiles/tools/.tmux.conf ~/.tmux.conf
mkdir ~/.config/kitty
ln -s ~/dotfiles/tools/kitty.conf ~/.config/kitty/kitty.conf

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
curl -L https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh > ~/dotfiles/git/.git-prompt.sh
ln -s ~/dotfiles/git/.git-prompt.sh ~/.git-prompt.sh
ln -s ~/.git/hooks ~/dotfiles/git/hooks

# Install Homebrew and use Brewfile with Cask
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# If brew already installed on another existing user, just give permissions to admin group
sudo chgrp -R admin /opt/homebrew/
sudo chmod -R 770 /opt/homebrew/

brew doctor
brew tap Homebrew/bundle # https://github.com/Homebrew/homebrew-bundle
brew bundle install
brew bundle check # Check everything anything to install/upgrade
brew cleanup # Delete cask downloads

# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install

# Install Ruby + Bundler & Rubocop
rbenv install 2.7.6
rbenv global 2.7.6
gem install bundler
gem install rubocop
gem install rubocop-rspec

ln -sf ~/dotfiles/ruby/.bundle/config ~/.bundle/config

mkdir ~/Downloads/music
mkdir ~/Downloads/video
mkdir ~/Downloads/screenshots

# Use Sexy Bash Prompt https://github.com/twolfson/sexy-bash-prompt
# (cd /tmp && git clone --depth 1 --config core.autocrlf=false https://github.com/twolfson/sexy-bash-prompt && cd sexy-bash-prompt && make install) && source ~/.bashrc
# my own copy is at bash/prompt

# Bash 4 in OS X
sudo bash -c "echo $(brew --prefix)/bin/bash >> /etc/shells"
chsh -s "$(brew --prefix)"/bin/bash

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Set highlight color to green
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

# Finder: Show hidden files on
defaults write com.apple.finder AppleShowAllFiles YES

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: Display full POSIX path as window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Finder: Always open everything in list view.
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Finder :Show the ~/Library folder
chflags nohidden ~/Library

# Finder :Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Finder: Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Finder Show the /Volumes folder
sudo chflags nohidden /Volumes

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable creation of metadata files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable creation of metadata files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Change screenshots destination folder
defaults write com.apple.screencapture location ~/Downloads/screenshots

# Enable subpixel font rendering on non-Apple LCDs
# Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
defaults write NSGlobalDomain AppleFontSmoothing -int 1

# Enable HiDPI display modes (requires restart)
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

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

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Dock: Move to the left & restart it
defaults write com.apple.dock orientation left

# Dock: Remove all app icons
defaults write com.apple.dock persistent-apps -array

# Dock: Set the icon size to 36 pixels
defaults write com.apple.dock tilesize -int 40

# Dock: Make icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Restart dock to apply changes
killall Dock

# Disable handoff
defaults -currentHost write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool no
defaults -currentHost write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool no

# Disable Spell Check in Every Application system-wide
defaults write com.apple.notes NSAutomaticSpellingCorrectionEnabled -bool false

# Disable Shadow for Window Screenshots
defaults write com.apple.screencapture disable-shadow -bool TRUE
killall SystemUIServer

# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false

# Disable font smoothing. 0: disable 1: light 2: medium (default) 3: strong
defaults -currentHost write -g AppleFontSmoothing -int 0

# Computer Name
scutil --set ComputerName "bcq"
scutil --set LocalHostName "bcq"
scutil --set HostName "bcq"

# Use own SublimeText config
# macos
rm -rf ~/Library/Application\ Support/Sublime\ Text/Packages/User
ln -sfn ~/dotfiles/sublimetext ~/Library/Application\ Support/Sublime\ Text/Packages/User

# linux
rm -rf ~/.config/sublime-text/Packages/User
ln -sfn ~/dotfiles/sublimetext ~/.config/sublime-text/Packages/User

# Divvy shortcuts setup: (will prompt on Safari to confirm)
open -a Safari "$(< ~/dotfiles/tools/divvy)"
