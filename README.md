# .dotfiles

My configuration files 📝

```
cd ~/dotfiles
chmod +x makesymlinks.sh
./makesymlinks.sh
```

```
brew install bash
brew install diff-so-fancy # Making git diffs better in command line
brew install elixir
brew install git
brew install homebrew/versions/bash-completion2
brew install httpie
brew install hub # github's command line
brew install libxml2
brew install mas # Mac App Store command line interface
brew install michaeldfallen/formula/git-radar # improve git repo info
brew install mongo
brew install mysql
brew install postgresql
brew install rbenv ruby-build
brew install redis
brew install wget
brew install wifi-password # display current wifi password
brew tap joshuaclayton/formulae
brew install unused

brew install caskroom/cask/brew-cask
brew cask install appcleaner # unistall apps totally
brew cask install choosy # lets you choose browser to open url
brew cask install coconutbattery # control mac / iphone battery life
brew cask install commandq # delay app quitting
brew cask install disk-inventory-x # check disk usage
brew cask install divvy # move windows around
brew cask install dropbox
brew cask install duet # use ipad as secondary screen
brew cask install firefox
brew cask install garmin-express
brew cask install gimp
brew cask install google-chrome
brew cask install gopro-studio
brew cask install image2icon
brew cask install iterm2
brew cask install keka # file compression/uncompression
brew cask install libreoffice
brew cask install little-snitch # network monitor
brew cask install macdown # markdown editor
brew cask install micro-snitch # microphone/webcam vigilante
brew cask install psequel # psql gui
brew cask install robomongo # mongo gui
brew cask install sequel-pro # sql gui
brew cask install smcfancontrol # check temp & fan revs
brew cask install skype
brew cask install slack
brew cask install spotify
brew cask install sublime-text
brew cask install subtitles
brew cask install telegram
brew cask install trailer # github repo PR/issue watch
brew cask install transmission
brew cask install vlc
brew cask install xscope # graphical tools
```

``` 
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

# XCode dev tools install
xcode-select --install

# Computer Name
scutil --set ComputerName "bcq"
scutil --set LocalHostName "bcq"
scutil --set HostName "bcq"
```

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
On Find&Replace panel:
Where: `-*/log/*`

# Little snitch installation
```
open /usr/local/Caskroom/little-snitch/3.7.2/Little\ Snitch\ Installer.app
```

# Extra manual downloads:
Chrome Canary
CCMenu ?
TrailerApp?

# Ruby
```
rbenv install 2.3.1
rbenv global 2.3.1
gem install bundler
```

# Nokigiri on MacOS sierra
bundle config build.nokogiri --use-system-libraries=true --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk/usr/include/libxml2
bundle install
brew unlink xz; bundle install; brew link xz
http://stackoverflow.com/questions/40038953/installing-nokogiri-on-mac-os-sierra-10-12

# Heroku 
https://devcenter.heroku.com/articles/heroku-command-line

# Check periodically 
awk '{print $1}' ~/.bash_history | sort | uniq -c | sort -n

sed 's/|/\n/g' ~/.bash_history | awk '{CMD[$1]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10

To find out most used commands and thing about making aliases
```

# Add private key to OSX Keychain
```
ssh-add -K ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa &>/dev/null
```

# Download all Organization repos (private ones as well)
```
curl -u bertocq -s https://api.github.com/orgs/<ORG_NAME>/repos?per_page=200 | ruby -rubygems -e 'require "json"; JSON.load(STDIN.read).each { |repo| %x[git clone #{repo["ssh_url"]} ]}'
```

# Chrome config: 
Gmail as email handler
http://apple.stackexchange.com/a/112624

# macos Shortuct:
> Preferences > Keyboard > Shortcuts > Keyboard > Move focus to next window > Cmd+¡