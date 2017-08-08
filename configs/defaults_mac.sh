#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until configurator has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Set dock behaviour to minimize windows to application icon
defaults write com.apple.dock minimize-to-application -bool yes

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Restart automatically on freeze
sudo systemsetup -setrestartfreeze on

# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Disable hot corners
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################

# Disable swipe gestures from Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

###############################################################################
# Setup Alfred                                                                #
###############################################################################

# Allow Apps folder
defaults write com.runningwithcrayons.Alfred-Preferences-3 dropbox.allowappsfolder -bool TRUE
# Set sync folder
defaults write com.runningwithcrayons.Alfred-Preferences-3 syncfolder -string "$HOME/Dropbox/Apps/Alfred"

###############################################################################
# Setup iTerm                                                                 #
###############################################################################

# Set sync folder
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/Dropbox/Apps/iTerm" 
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool TRUE
