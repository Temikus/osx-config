require 'logger'
$LOG = Logger.new(STDOUT)

#Homebrew prefix (SED escaped):
homebrew_prefix='\/Users\/temikus\/.homebrew'

# Packages to install
homebrew_packages = ['wget',
                     'mtr',
                     'autojump',
                     'zsh-syntax-highlighting',
                     'ack',
                     'watch']
cask_packages = ['google-chrome',
                 'iterm2-beta',
                 'skype',
                 'alfred',
                 'sublime-text3',
                 'dropbox',
                 'google-drive',
                 'flux',
                 'mpv',
                 'sourcetree']

## Cask packages that are not installed into ~/Applications and don't need to be zapped
cask_package_exceptions = ['ksdiff']

# Git settings
git_config_global_user_name='Artem Yakimenko'
git_config_global_user_email='code@temik.me'
git_config_global_push_default='simple'
git_config_global_core_excludesfile='~/.gitignore_global'

#desc 'Install the whole shebang'
task :install => [:'preinstall:all', :'homebrew:install', :'cask:install', :'config:all', :'git:configure']

namespace :preinstall do

  desc 'Run all preinstall tasks'
  task :all => [:update_submodules]

  desc 'Recursively update all submodules'
  task :update_submodules do
    $LOG.info('Setting up git submodules...')
    system('git submodule update --init --recursive')
  end
  
  desc 'Install Xcode CLI tools'
  task :xcode_select do
    $LOG.info('Installing Xcode CLI tools...')
    system('xcode-select --install')
  end
end

namespace :homebrew do

  desc 'Install Homebrew, Cask and packages'
  task :install => [:install_homebrew, :install_homebrew_packages]

  desc 'Install Homebrew'
  task :install_homebrew do
    $LOG.info('Installing Homebrew...')
    system('curl -L https://raw.githubusercontent.com/Homebrew/install/master/install -o /tmp/homebrew_install.rb')
    system("sed -i .bak 's/HOMEBREW_PREFIX = .*/HOMEBREW_PREFIX = \"#{homebrew_prefix}\"/' /tmp/homebrew_install.rb")
    system('ruby /tmp/homebrew_install.rb')
    system('source ~/.zshenv')
  end

  desc 'Install Homebrew packages'
  task :install_homebrew_packages do
    $LOG.info('Installing Homebrew packages...')
    homebrew_packages.each do |package|
       system("brew install #{package}")
    end
  end

end

namespace :cask do
  desc 'Install Cask and packages'
  task :install => [:install_cask_packages ]

  task :install_cask_packages do
    $LOG.info('Installing Cask packages...')
    cask_packages.each do |package|
      system("brew cask install --no-binaries #{package}")
    end

    $LOG.info('Copying apps to /Applications...')
    # We're piggybacking off cask to install the necessary apps and get the latest versions
    cask_apps = `find /opt/homebrew-cask/Caskroom -name "*.app" -type d -depth 3`.split("\n")
    cask_apps.each do |file|
      system("cp -r '#{file}' /Applications")
    end

    $LOG.info('Zapping packages in ~/Applications')
    cask_packages.each do |package|
      system("brew cask zap #{package}")
    end

    $LOG.info('Installing Cask exceptions')
    cask_package_exceptions.each do |package|
       system("brew cask install #{package}")
    end
  end

end

namespace :git do
  desc 'Set git settings'
  task :configure => [:set_identity, :set_defaults]

  desc 'Set Git identity'
  task :set_identity do
    $LOG.info('Setting up git identity...')
    system("git config --global user.name #{git_config_global_user_name}")
    system("git config --global user.email #{git_config_global_user_email}")
  end

  desc 'Set Git defaults'
  task :set_defaults do
    $LOG.info('Setting up git settings...')
    system("git config --global push.default #{git_config_global_push_default}")
    system("git config --global core.excludesfile #{git_config_global_core_excludesfile}")
  end

end

namespace :configs do
  desc 'Set all configs'
  task :all => [:sublime_text, :mac_defaults]

  task :sublime_text do
    $LOG.info('Copying sublime config and installing package control...')
    system('cp ./configs/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings')
    system('curl https://packagecontrol.io/Package%20Control.sublime-package -o ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages/')
  end

  task :mac_defaults do
    $LOG.info('Setting up Mac defaults. This will require your password...')
    system('./configs/defaults_mac.sh')
  end

end

