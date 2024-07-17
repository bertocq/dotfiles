# Notes on manual tasks to reproduce my current installation

## If work setup

export ENV_SUFFIX=.work to /etc/profile or /etc/bashrc

## Add private key to OSX Keychain
```
ssh-add -K ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa &>/dev/null
```

## macOS Shortcuts:
> Preferences > Keyboard Shortcuts > Keyboard > Move focus to next window > Cmd+¡
> Preferences > Keyboard Shortcuts > App Shortcuts > "Duplicate tab" Cmd+shift+E
> Preferences > Keyboard Shortcuts > App Shortcuts > "Check Document Now" Cmd+' (to avoid collision with Cmd+¡)
> Preferences > Keyboard Shortcuts > Mission Control > Disable ^↑ & ^↓ that would collide with Sublimetext shortcuts

### Chrome extensions config
chrome://extensions > Keyboard shortcuts
- OneTab:
  - "Display OneTab": Alt+Shift+1
  - "Send the current tab to OneTab": Alt+Shift+W
- Rearrange Tabs:
  - "Move active tab to left": Command+Ctrl+Left Arrow
  - "Move active tab to right": Command+Ctrl+Right Arrow

## macOS Matrix RedPill ScreenSaver
https://github.com/lpar/RedPill

## Unhide Garmin Fenix 3 Newfiles hidden folder
cd /Volumes/GARMIN/GARMIN
sudo chflags nohidden ./NEWFILES

## Configure iTerm editor
go to iTerm -> Preferences -> Profiles -> Advanced -> Semantic History
from the dropdown, choose Open with Editor and from the right dropdown choose your editor of choice

## Libreoffice (or any other cask) with SSL problems
CURL_SSL_BACKEND=secure-transport HOMEBREW_NO_ENV_FILTERING=1 brew install libreoffice
