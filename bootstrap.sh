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
sleep_timeout=5

debug()
{
	[ "$verbose" ] && echo ">>> $*";
}

timeout()
{
	#Regulates timeout after output-intensive commands
	sleep $timeout
}

show_help()
{

  echo "Usage: `basename $0` [-h|--help] [-v|--verbose] [options]"
	echo ""
	echo "Options:"
	echo "--with-puppet - Install puppet client on the machine"

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
	echo "Running puppet manifests..."
	puppet apply --debug --modulepath=./modules appinstall.pp
}

install_homebrew()
{
	echo "Installing Homebrew..."
	Using the standard ruby install pipe.
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	timeout
}

install_homebrew_packages()
{
	brew install wget mtr autojump zsh-syntax-highlighting
}

install_cask()
{
	brew install caskroom/cask/brew-cask
	brew tap caskroom/versions
}

install_cask_packages()
{
	brew cask install google-chrome iterm2-beta skype alfred
}

debug "Launching with settings:"
debug "with_puppet=$with_puppet"
debug "without_homebrew=$without_homebrew"

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
fi


echo "All done!"

exit 0
