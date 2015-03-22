#!/bin/bash

# Parse options
for opt in "$@"
do
    case "$opt" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--verbose)
      verbose=1
        ;;
    --with-puppet)
      with_puppet=true
        ;;
    --without-homebrew)
        without_homebrew=true
        ;;
    esac
done

# Default settings
with_puppet=${with_puppet:-false}
without_homebrew=${without_homebrew:-false}
puppet_manifest_location=${puppet_manifest_location:-"./puppet/appinstall.pp"}
puppet_modules_location=${puppet_modules_location:-"./puppet/modules"}

# Packages to install
homebrew_packages=(wget mtr autojump zsh-syntax-highlighting ack watch)
kask_packages=(google-chrome iterm2-beta skype alfred sublime-text3 dropbox google-drive flux mplayerx ksdiff sourcetree)

# Git settings
git_config_global_user_name="Artem Yakimenko"
git_config_global_user_email="code@temik.me"
git_config_global_push_default='simple'
git_config_global_core_excludesfile='~/.gitignore_global'

debug()
{
  [ "$verbose" ] && echo ">>> $*";
}

#################################
##########Color output###########
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)

function red() {
    echo -e "$RED$*$NORMAL"
    }
function green() {
    echo -e "$GREEN$*$NORMAL"
    }
function yellow() {
    echo -e "$YELLOW$*$NORMAL"
    }

#################################

timeout()
{
  #Regulates timeout after output-intensive commands
  sleep 5
}

show_help()
{
  echo "Usage: `basename $0` [-h|--help] [-v|--verbose] [options]"
  echo ""
  echo "Options:"
  echo "--with-puppet - Install puppet client on the machine"
  echo "--without-homebrew - Do not set up homebrew or homebrew-cask"

  exit 0
}

#Cleaning up
cleanup()
{
  rm /tmp/puppet-*.dmg
  hdiutil unmount /Volumes/puppet-*
  rm /tmp/facter-*.dmg
  hdiutil unmount /Volumes/facter-*
}

download_puppet()
{
  curl -o /tmp/puppet-latest.dmg https://downloads.puppetlabs.com/mac/puppet-latest.dmg
}

download_facter()
{
  curl -o /tmp/facter-2.4.0.dmg https://downloads.puppetlabs.com/mac/facter-2.4.0.dmg
}

install_puppet()
{
  hdiutil mount /tmp/puppet-latest.dmg
  hdiutil mount /tmp/facter-2.4.0.dmg
  sudo installer -pkg /Volumes/puppet-*/puppet-*.pkg -target /
}

install_facter()
{
  hdiutil mount /tmp/facter-2.4.0.dmg
  sudo installer -pkg /Volumes/facter-*/facter-*.pkg -target /
}

run_puppet_manifests()
{
  yellow "Running puppet manifests..."
  puppet apply --debug --modulepath=$puppet_modules_location $puppet_manifest_location
}

install_homebrew()
{
  yellow "Installing Homebrew..."
  #Using the standard ruby install pipe.
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  timeout
}

install_homebrew_packages()
{
  yellow "Installing homebrew packages..."
  brew install $homebrew_packages
}

install_cask()
{
  brew install caskroom/cask/brew-cask
  brew tap caskroom/versions
}

install_cask_packages()
{
  yellow "Installing cask packages..."
  debug "Will install $kask_packages"
  brew cask install $kask_packages

  timeout

  yellow "Copying apps to /Applications..."
  # We're piggybacking off cask to install the necessary apps and get the latest versions
  find /opt/homebrew-cask/Caskroom -name "*.app" -type d -depth 3 | while read app_file_path; do
    debug "Copying $app_file_path to /Applications"
    cp -r "$app_file_path" /Applications
  done

  brew cask zap $kask_packages

}

git_setup()
{

  yellow "Setting up git..."

  git config --global user.name $git_config_global_user_name
  git config --global user.email $git_config_global_user_email

  git config --global push.default $git_config_global_push_default
  git config --global core.excludesfile $git_config_global_core_excludesfile

}

copy_oh_my_zsh_custom()
{
  yellow "Copying oh-my-zsh custom configs..."
  cp -r ./oh-my-zsh/* ~/.oh-my-zsh/custom/ || { red 'Could not copy oh-my-zsh configs' ; exit 1; }
}

update_git_submodules()
{

  yellow "Setting up git submodules..."

  git submodule init || { red 'Could not init submodules' ; exit 1; }
  git submodule update || { red 'Could not update submodules' ; exit 1; }
}

setup_sublime_text()
{

  yellow "Copying sublime user config..."
  cp ./configs/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings

  yellow "Setting up Sublime puppet module..."
  mkdir ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/SublimePuppet
  git clone https://github.com/russCloak/SublimePuppet.git ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/SublimePuppet

}

setup_defaults()
{
  yellow "Setting up Mac defaults. This will require your password..."
  ./configs/defaults_mac.sh
}

debug "Launching with settings:"
debug "with_puppet=$with_puppet"
debug "without_homebrew=$without_homebrew"
debug "without_cask=$without_cask"
debug "puppet_manifest_location=$puppet_manifest_location"
debug "puppet_modules_location=$puppet_modules_location"

git_setup
update_git_submodules
copy_oh_my_zsh_custom

#Install puppet if flag is supplied
if [[ $with_puppet == true ]]; then

  if [[ ! -x /usr/bin/puppet ]]; then
    cleanup
    download_puppet
    install_puppet
  fi

  if [[ ! -x /usr/bin/facter ]]; then
    cleanup
    download_puppet
    install_facter
  fi
  run_puppet_manifests
fi

if [[ $without_homebrew == false ]]; then
  install_homebrew
  install_homebrew_packages

  install_cask
  install_cask_packages
fi

setup_sublime_text
setup_defaults

echo "All done! Some changes will require a restart."

exit 0
