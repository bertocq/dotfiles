# .dotfiles

My configuration files 📝

```
cd ~/dotfiles
chmod +x makesymlinks.sh
./makesymlinks.sh
```

brew install bash
brew install git
brew install homebrew/versions/bash-completion2
brew install httpie
brew install hub
brew install libxml2
brew install michaeldfallen/formula/git-radar
brew install mongo
brew install mysql
brew install postgresql
brew install rbenv ruby-build
brew install redis
brew install webkit2png
brew install wget
brew install wifi-password

brew install caskroom/cask/brew-cask
brew cask install appcleaner
brew cask install choosy
brew cask install coconutbattery
brew cask install commandq
brew cask install disk-inventory-x
brew cask install divvy
brew cask install dropbox
brew cask install duet
brew cask install firefox
brew cask install garmin-express
brew cask install gimp
brew cask install google-chrome
brew cask install gopro-studio
brew cask install image2icon
brew cask install iterm2
brew cask install keka
brew cask install libreoffice
brew cask install little-snitch
brew cask install macdown
brew cask install micro-snitch
brew cask install psequel
brew cask install robomongo
brew cask install sequel-pro
brew cask install smcfancontrol
brew cask install skype
brew cask install slack
brew cask install spotify
brew cask install sublime-text
brew cask install subtitles
brew cask install telegram
brew cask install trailer
brew cask install transmission
brew cask install vlc
brew cask install xscope


# Sexy Bash Prompt
(cd /tmp && git clone --depth 1 --config core.autocrlf=false https://github.com/twolfson/sexy-bash-prompt && cd sexy-bash-prompt && make install) && source ~/.bashrc

# Bash 4 in OS X
brew install bash
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

# Install all available software updates
sudo softwareupdate -ia

# Extra configs:

Divvy: Copy .divvy content and paste on to Safari search bar

# TODO: move sublime config from dropbox to git private repo
# https://bitbucket.org/bertocq/sublimetext_config
Sublimetext: Once config files are downloaded from dropbox, symlink with:
```
cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/
rm -r User
ln -s ~/Dropbox/Sublime/User
```

# Extra manual downloads:
Chrome Canary
CCMenu ?
TrailerApp?

# Ruby
rbenv install 2.3.1
rbenv global 2.3.1
gem install bundler

# Nokigiri on MacOS sierra
bundle config build.nokogiri --use-system-libraries=true --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk/usr/include/libxml2
bundle install
http://stackoverflow.com/questions/40038953/installing-nokogiri-on-mac-os-sierra-10-12

# Heroku 
https://devcenter.heroku.com/articles/heroku-command-line

# Computer Name
scutil --set ComputerName "bcq"
scutil --set LocalHostName "bcq"
scutil --set HostName "bcq"



