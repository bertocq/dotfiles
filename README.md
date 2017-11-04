# My Config script and setup instructions 👹

## Little snitch installation
```
open /usr/local/Caskroom/little-snitch/3.7.2/Little\ Snitch\ Installer.app
```

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

## Download all Organization repos (private ones as well)
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

## macos Shortcut:
> Preferences > Keyboard > Shortcuts > Keyboard > Move focus to next window > Cmd+¡

## Periodically update Brewfile
```
cd ~/dotfiles
brew bundle dump --force
```
