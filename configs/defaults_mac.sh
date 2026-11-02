#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until configurator has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable “natural” (Lion-style) scrolling
# Logi Options+ overrides this per mouse and defaults to natural. Set it in the
# app: <device> → Point & Scroll → Scroll wheel → Direction: Standard.
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en-AU" "ru-AU"
defaults write NSGlobalDomain AppleLocale -string "en_AU"

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
# systemsetup prints a spurious "### Error:-99 ... InternetServices.m" on recent macOS
# even when it succeeds, so drop stderr too.
sudo systemsetup -settimezone "Australia/Sydney" > /dev/null 2>&1

###############################################################################
# Finder                                                                      #
###############################################################################

# Always open everything in Finder's list view
defaults write com.apple.finder FXPreferredViewStyle Nlsv

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show the ~/Library folder. Finder's "Show Library Folder" view option flips the same flag.
chflags nohidden ~/Library

# Show the status bar in Finder windows
defaults write com.apple.finder ShowStatusBar -bool true

###############################################################################
# Dock and windows                                                            #
###############################################################################

# Automatically hide and show the Dock (for smaller laptops)
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 46

# Minimise windows into their app icon
defaults write com.apple.dock minimize-to-application -bool true

# No gaps between tiled windows
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

###############################################################################
# TimeMachine                                                                 #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################

# Disable swipe gestures from Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

# Use the system-native print preview dialog
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

###############################################################################
# Amphetamine                                                                 #
###############################################################################

# Make sure Amphetamine is not running as otherwise settings won't apply
if pgrep -q "Amphetamine"; then
    echo "Quitting Amphetamine to apply settings..."
    osascript -e 'tell application "Amphetamine" to quit'
    sleep 2
fi

# Set menu bar icon
defaults write com.if.Amphetamine "Icon Style" 2
# Disable welcome message
defaults write com.if.Amphetamine "Show Welcome Window" 0
# Use 24 hour time format
defaults write com.if.Amphetamine "Use 24 Hour Clock" 1
