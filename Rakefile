require 'logger'
$LOG = Logger.new(STDOUT)

puppet_manifest_location ||= "./puppet/appinstall.pp"
puppet_modules_location ||= "./puppet/modules"

# Packages to install
homebrew_packages = ["wget", "mtr", "autojump", "zsh-syntax-highlighting", "ack", "watch"]
cask_packages = [ "google-chrome", "iterm2-beta", "skype", "alfred", "sublime-text3", "dropbox", "google-drive", "flux", "mplayerx", "sourcetree"]
## Cask packages that are not installed into ~/Applications and don't need to be zapped
cask_package_exceptions = ["ksdiff"]

# Git settings
git_config_global_user_name="Artem Yakimenko"
git_config_global_user_email="code@temik.me"
git_config_global_push_default='simple'
git_config_global_core_excludesfile='~/.gitignore_global'


# def timeout
#   sleep 5
# end

#Cleaning up

# namespace :puppet do

#   desc "Install Puppet and Facter"
#   task :install => [:download, :install_puppet, :install_facter]

#   desc "Download puppet"
#   task :download do
#     `curl -o /tmp/puppet-latest.dmg https://downloads.puppetlabs.com/mac/puppet-latest.dmg`
#     `curl -o /tmp/facter-latest.dmg https://downloads.puppetlabs.com/mac/facter-latest.dmg`
#   end

#   desc "Install puppet"
#   task :install_puppet do
#     `hdiutil mount /tmp/facter-latest.dmg`
#     `sudo installer -pkg /Volumes/facter-*/facter-*.pkg -target /`
#   end

#   desc "Install facter"
#   task :install_facter do
#     `hdiutil mount /tmp/facter-latest.dmg`
#     `sudo installer -pkg /Volumes/facter-*/facter-*.pkg -target /`
#   end

#   desc "Run manifests"
#   task :run do
#     $LOG.info("Running puppet manifests...")
#     `puppet apply --debug --modulepath=#{puppet_modules_location} #{puppet_manifest_location}`
#   end

#   desc "Cleanup state"
#   task :clean => [:dependent, :tasks] do

#     `rm /tmp/puppet-*.dmg`
#     `hdiutil unmount /Volumes/puppet-*`
#     `rm /tmp/facter-*.dmg`
#     `hdiutil unmount /Volumes/facter-*`
#   end
# end

namespace :homebrew do

  desc "Install Homebrew, Cask and packages"
  task :install => [:install_homebrew, :install_homebrew_packages]

  desc "Install Homebrew"
  task :install_homebrew do
    $LOG.info("Installing Homebrew...")
    `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
  end

  desc "Install Homebrew packages"
  task :install_homebrew_packages do
    $LOG.info("Installing Homebrew packages...")
    homebrew_packages.each do |package|
       `brew install #{package}`
    end
  end


end

namespace :cask do
  desc "Install Cask and packages"
  task :install => [:install_cask, :install_cask_packages ]

  desc "Install Homebrew"
  task :install_cask do
    $LOG.info("Installing Cask...")
    `brew install caskroom/cask/brew-cask`
    `brew tap caskroom/versions`
  end

  task :install_cask_packages do
    $LOG.info("Installing Cask packages...")
    cask_package.each do |package|
      `brew cask install #{package}`
    end

    $LOG.info("Copying apps to /Applications...")
    # We're piggybacking off cask to install the necessary apps and get the latest versions
    cask_apps = `find /opt/homebrew-cask/Caskroom -name "*.app" -type d -depth 3`
    cask_apps.each do |file|
      `cp -r #{file} /Applications`
    end

    $LOG.info("Zapping packages in ~/Applications")
    cask_package.each do |package|
      `brew cask zap #{package}`
    end


    $LOG.info("Installing Cask exceptions")
    cask_package_exceptions.each do |package|
       `brew cask install #{package}`
    end
  end
end

namespace :git do
  desc "Set git settings"
  task :configure => [:set_identity, :set_defaults]

  desc "Set Git identity"
  task :set_identity do
    $LOG.info("Setting up git identity...")
    `git config --global user.name #{git_config_global_user_name}`
    `git config --global user.email #{git_config_global_user_email}`
  end

  desc "Set Git defaults"
  task :set_defaults do
    $LOG.info("Setting up git settings...")
    `git config --global user.name #{git_config_global_user_name}`
    `git config --global user.email #{git_config_global_user_email}`
  end
end

# copy_oh_my_zsh_custom()
# {
#   yellow "Copying oh-my-zsh custom configs..."
#   cp -r ./oh-my-zsh/* ~/.oh-my-zsh/custom/ || { red 'Could not copy oh-my-zsh configs' ; exit 1; }
# }

# update_git_submodules()
# {

#   yellow "Setting up git submodules..."

#   git submodule init || { red 'Could not init submodules' ; exit 1; }
#   git submodule update || { red 'Could not update submodules' ; exit 1; }
# }

# setup_sublime_text()
# {

#   yellow "Copying sublime user config..."
#   cp ./configs/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings

#   yellow "Setting up Sublime puppet module..."
#   mkdir ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/SublimePuppet
#   git clone https://github.com/russCloak/SublimePuppet.git ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/SublimePuppet

# }

# setup_defaults()
# {
#   yellow "Setting up Mac defaults. This will require your password..."
#   ./configs/defaults_mac.sh
# }

# git_setup
# update_git_submodules
# copy_oh_my_zsh_custom

# #Install puppet if flag is supplied
# if [[ $with_puppet == true ]]; then

#   if [[ ! -x /usr/bin/puppet ]]; then
#     cleanup
#     download_puppet
#     install_puppet
#   fi

#   if [[ ! -x /usr/bin/facter ]]; then
#     cleanup
#     download_puppet
#     install_facter
#   fi
#   run_puppet_manifests
# fi

# if [[ $without_homebrew == false ]]; then
#   install_homebrew
#   install_homebrew_packages

#   install_cask
#   install_cask_packages
# fi

# setup_sublime_text
# setup_defaults

# echo "All done! Some changes will require a restart."

# exit 0
