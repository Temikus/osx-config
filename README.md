# osx-config
Quick OSX workstation configuration using minimalist tools.

This set of scripts was designed to set up a Mac workstation with minimal
intrusion and interference with existing mac management tools, like
Munki/Chef/Puppet, but still allowing to use them if needed.

## Usage
	git clone https://github.com/Temikus/osx-config

	cd osx-config && bootstrap.sh


## Additional options

	--with-puppet - Install puppet client on the machine
  --without-homebrew - Do not set up homebrew or homebrew-cask