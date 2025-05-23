#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until configurator has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en-AU" "ru-AU"
defaults write NSGlobalDomain AppleLocale -string "en_AU"

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "Australia/Sydney" > /dev/null

###############################################################################
# Energy saving                                                               #
###############################################################################

# Enable WakeOnLan
#sudo pmset -a womp 1

###############################################################################
# Screen                                                                      #
###############################################################################

# Enable subpixel font rendering on non-Apple LCDs
# Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
#defaults write NSGlobalDomain AppleFontSmoothing -int 1

# Enable HiDPI display modes (requires restart)
#sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Always open everything in Finder's list view
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Allow selection of text in quicklook windows.
defaults write com.apple.finder QLEnableTextSelection -bool true

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show the ~/Library folder
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

# Show the /Volumes folder
sudo chflags nohidden /Volumes

# Automatically hide and show the Dock (for smaller laptops)
defaults write com.apple.dock autohide -bool true

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
# Setup iTerm                                                                 #
###############################################################################

# Set sync folder
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/Dropbox/Apps/iTerm"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool TRUE

###############################################################################
# Amphetamine                                                                 #
###############################################################################

# Check if Amphetamine is installed
if ! mas list | grep -q "Amphetamine"; then
    echo "Amphetamine not installed. Checking for Mac App Store CLI (mas)..."
    if ! command -v mas &> /dev/null; then
        echo "Mac App Store CLI (mas) is not installed."
        read -p "Would you like to install mas using Homebrew? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if command -v brew &> /dev/null; then
                echo "Installing mas..."
                brew install mas
            else
                echo "Homebrew is not installed. Please install Homebrew first."
                echo "Visit https://brew.sh for instructions."
                exit 1
            fi
        else
            echo "Skipping Amphetamine installation."
        fi
    fi

    # Try installing Amphetamine if mas is now available
    if command -v mas &> /dev/null; then
        echo "Installing Amphetamine from the Mac App Store..."
        mas install 937984704
    fi
fi

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
