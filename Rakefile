require 'io/console'                                                                                                       
require 'logger'
$LOG_GLOBAL = Logger.new(STDOUT)

#TODO: Steps requiring separate action should wait on input(e.g Alfred powerpack , fonts config, etc.)

# Install into a custom prefix?
homebrew_custom_prefix = false

# If installing to a custom Homebrew prefix (SED escaped):
homebrew_prefix='\/Users\/temikus\/.homebrew'
homebrew_repo='\/Users\/temikus\/.homebrew\/Homebrew'
# PATH vars for custom prefix
homebrew_path = '/Users/temikus/.homebrew/sbin:/Users/temikus/.homebrew/bin'

# Packages to install
homebrew_packages = %w(wget mtr autojump zsh-syntax-highlighting ack watch fzf mpv nmap)
cask_packages = %w(alfred flux fork iterm2-beta jetbrains-toolbox keybase)

# Cask packages that do not posess a SHA256 checksum
cask_package_exceptions = %w(skype dropbox)

# Git settings
git_config_global_user_name='Artem Yakimenko'
git_config_global_user_email='code@temik.me'
git_config_global_push_default='simple'
git_config_global_core_excludesfile='~/.gitignore_global'

# Helper module
def continue(message = nil)
  puts "#{message}" if message                                                                                                               
  print 'Press any key to continue...'
  STDIN.getch                                                                                                              
  print "            \r" # extra space to overwrite in case next sentence is short                                                                                                              
end  

#desc 'Install the whole shebang'
task :install => [:'preinstall:all', 
                  :'homebrew:install',
                  :'cask:install',
                  :'config:all',
                  :'git:configure',
                  :'gcloud:install']

namespace :preinstall do

  desc 'Run all preinstall tasks'
  task :all => [:update_submodules, :xcode_select]

  desc 'Recursively update all submodules'
  task :update_submodules do
    $LOG_GLOBAL.info('Setting up git submodules...')
    system('git submodule update --init --recursive')
    continue
  end

  desc 'Install Xcode CLI tools'
  task :xcode_select do
    $LOG_GLOBAL.info('Installing Xcode CLI tools...')
    system('xcode-select --install')
    continue
    $LOG_GLOBAL.info('Running Xcode license agreement check...')
    system('sudo xcodebuild -license')
    continue
  end
end

namespace :homebrew do

  desc 'Install Homebrew, Cask and packages'
  task :install => [:install_homebrew, :install_homebrew_packages]

  desc 'Install Homebrew'
  task :install_homebrew do
    if homebrew_custom_prefix
      $LOG_GLOBAL.info('Installing Homebrew into a custom prefix...')
      system('curl -L https://raw.githubusercontent.com/Homebrew/install/master/install -o /tmp/homebrew_install.rb')
      system("sed -i .bak 's/HOMEBREW_PREFIX = .*/HOMEBREW_PREFIX = \"#{homebrew_prefix}\".freeze/' /tmp/homebrew_install.rb")
      system("sed -i .bak 's/HOMEBREW_REPOSITORY = .*/HOMEBREW_REPOSITORY = \"#{homebrew_repo}\".freeze/' /tmp/homebrew_install.rb")
      system('ruby /tmp/homebrew_install.rb')
      #TODO: Check if this is working right next time
      puts 'The terminal will attempt to set the correct path variables'
      continue
      ENV['PATH'] = "#{homebrew_path}:#{ENV['PATH']}"
    else
      $LOG_GLOBAL.info('Installing Homebrew...')
      system('/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"')
    end
    continue
    #Tap alternative versions repo for sublime, iterm, etc.
    system('brew tap caskroom/versions')
  end

  desc 'Install Homebrew packages'
  task :install_homebrew_packages do
    $LOG_GLOBAL.info('Installing Homebrew packages...')
    continue
    homebrew_packages.each do |package|
       system("brew install #{package}")
    end
  end

end

namespace :cask do
  desc 'Install Cask and packages'
  task :install => [:install_cask_packages]

  task :install_cask_packages do
    $LOG_GLOBAL.info('Installing Cask packages...')
    continue
    cask_packages.each do |package|
      system("brew cask install --require-sha #{package}")
    end

    $LOG_GLOBAL.info('Installing Cask exceptions')
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
    $LOG_GLOBAL.info('Setting up git identity...')
    continue
    system("git config --global user.name #{git_config_global_user_name}")
    system("git config --global user.email #{git_config_global_user_email}")
  end

  desc 'Set Git defaults'
  task :set_defaults do
    $LOG_GLOBAL.info('Setting up git settings...')
    continue
    system("git config --global push.default #{git_config_global_push_default}")
    system("git config --global core.excludesfile #{git_config_global_core_excludesfile}")
    system('git config --global include.path .gitaliases')
  end
end

namespace :config do
  desc 'Set mischellaneous configs'
  task :all => [:mac_defaults, :setup_ssh_keys]

  task :mac_defaults do
    $LOG_GLOBAL.info('Setting up Mac defaults. This will require your password...')
    continue
    system('./configs/defaults_mac.sh')
  end

  task :setup_ssh_keys do
    $LOG_GLOBAL.info('Generating SSH keys...')
    system('ssh-keygen -o -t rsa -b 4096')
  end
  
  # This should follow the dropbox config and installation, not active
  task :install_fonts do
    system('cp ~/Dropbox/Fonts/Inconsolata-dz.otf /Library/Fonts')
  end
end

namespace :gcloud do
  desc 'Install and configure gCloud'
  task :install => [:install_gcloud, :install_gcloud_components]

  task :install_gcloud do
    $LOG_GLOBAL.info('Installing Google Cloud SDK...')
    continue
    system('curl https://sdk.cloud.google.com | bash')
  end

  task :install_gcloud_components do
    $LOG_GLOBAL.info('Installing Google Cloud SDK...')
    continue
    system('gcloud components install kubectl')
  end
end
