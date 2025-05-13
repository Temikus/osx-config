#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until configurator has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false


# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################

# Disable swipe gestures from Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

###############################################################################
# Setup iTerm                                                                 #
###############################################################################

# Set sync folder
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/Dropbox/Apps/iTerm" 
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool TRUE
