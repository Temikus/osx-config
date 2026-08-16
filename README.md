# osx-config
Quick OSX workstation configuration using minimalist tools.

This set of scripts was designed to set up a Mac workstation with minimal
intrusion and interference with existing mac management tools, like
Munki/Chef/Puppet, but still allowing to use them if needed.

## Usage

```
	git clone https://github.com/Temikus/osx-config

	rake namespace:task
```
The available tasks are:
```
cask:install                           -- install cask and packages
configs:all                            -- set all configs
git:configure                          -- set git settings
git:set_defaults                       -- set git defaults
git:set_identity                       -- set git identity
homebrew:install                       -- install homebrew, cask and packages
homebrew:install_homebrew              -- install homebrew
homebrew:install_homebrew_packages     -- install homebrew packages
preinstall:all                         -- run all preinstall tasks
preinstall:update_submodules           -- recursively update all submodules
```

## Homebrew

`homebrew:install_homebrew` skips the install if `brew` is already on `PATH` or
in a standard prefix (`/opt/homebrew`, `/usr/local`). Otherwise it asks whether
to install into a prefix other than `/opt/homebrew` (default: no). Answering yes
untars the release into the given prefix instead of running the pkg installer -
Homebrew doesn't support non-standard prefixes, so there are no bottles and
everything builds from source.
