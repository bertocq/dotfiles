# Notes on manual tasks to reproduce my current installation

## Nokigiri on MacOS sierra
```
bundle config build.nokogiri --use-system-libraries=true --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk/usr/include/libxml2
bundle install
brew unlink xz; bundle install; brew link xz
http://stackoverflow.com/questions/40038953/installing-nokogiri-on-mac-os-sierra-10-12
```

## Add private key to OSX Keychain
```
ssh-add -K ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa &>/dev/null
```

## Clone all Organization repos (private ones as well)
```
curl -u bertocq -s https://api.github.com/orgs/<ORG_NAME>/repos?per_page=200 | ruby -rubygems -e 'require "json"; JSON.load(STDIN.read).each { |repo| %x[git clone #{repo["ssh_url"]} ]}'
```

## Chrome config:
### Gmail as email handler
http://apple.stackexchange.com/a/112624

### Chrome extensions config
chrome://extensions > Keyboard shortcuts
- OneTab:
  - "Display OneTab": Alt+Shift+1
  - "Send the current tab to OneTab": Alt+Shift+W
- Rearrange Tabs:
  - "Move active tab to left": Command+Ctrl+Left Arrow
  - "Move active tab to right": Command+Ctrl+Right Arrow

## macOS Shortcut:
> Preferences > Keyboard > Shortcuts > Keyboard > Move focus to next window > Cmd+¡

## macOS Matrix RedPill ScreenSaver
https://github.com/lpar/RedPill

## Unhide Garmin Fenix 3 Newfiles hidden folder
cd /Volumes/GARMIN/GARMIN
sudo chflags nohidden ./NEWFILES

## Configure iTerm editor
go to iTerm -> Preferences -> Profiles -> Advanced -> Semantic History
from the dropdown, choose Open with Editor and from the right dropdown choose your editor of choice
