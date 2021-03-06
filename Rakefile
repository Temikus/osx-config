require 'io/console'
require 'logger'
$LOG = Logger.new(STDOUT)

#TODO: Steps requiring separate action should wait on input(e.g Alfred powerpack , fonts config, etc.)

# Install into a custom prefix?
homebrew_custom_prefix = false

# If installing to a custom Homebrew prefix (SED escaped):
homebrew_prefix='\/Users\/temikus\/.homebrew'
homebrew_repo='\/Users\/temikus\/.homebrew\/Homebrew'
# PATH vars for custom prefix
homebrew_path = '/Users/temikus/.homebrew/sbin:/Users/temikus/.homebrew/bin'

# Dotfiles settings
dotfiles_path = '/Users/temikus/.dotfiles'

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
                  :'config:all',
                  :'git:configure',
                  :'gcloud:install']

namespace :preinstall do

  desc 'Run all preinstall tasks'
  task :all => [:xcode_select]

  desc 'Install Xcode CLI tools'
  task :xcode_select do
    $LOG.info('Installing Xcode CLI tools...')
    system('xcode-select --install')
    continue
    $LOG.info('Running Xcode license agreement check...')
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
      $LOG.info('Installing Homebrew into a custom prefix...')
      system('curl -L https://raw.githubusercontent.com/Homebrew/install/master/install -o /tmp/homebrew_install.rb')
      system("sed -i .bak 's/HOMEBREW_PREFIX = .*/HOMEBREW_PREFIX = \"#{homebrew_prefix}\".freeze/' /tmp/homebrew_install.rb")
      system("sed -i .bak 's/HOMEBREW_REPOSITORY = .*/HOMEBREW_REPOSITORY = \"#{homebrew_repo}\".freeze/' /tmp/homebrew_install.rb")
      system('ruby /tmp/homebrew_install.rb')
      #TODO: Check if this is working right next time
      puts 'The terminal will attempt to set the correct path variables'
      continue
      ENV['PATH'] = "#{homebrew_path}:#{ENV['PATH']}"
    else
      $LOG.info('Installing Homebrew...')
      system('/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"')
    end
    continue
    #Tap alternative versions repo for sublime, iterm, etc.
    system('brew tap caskroom/versions')
  end

  desc 'Install Homebrew packages'
  task :install_homebrew_packages do
    $LOG.info('Installing Homebrew packages...')
    continue

    Dir.chdir(dotfiles_path){
      %x[#{'brew bundle'}]
    }
  end
end

namespace :git do
  desc 'Set git settings'
  task :configure => [:set_identity, :set_defaults]

  desc 'Set Git identity'
  task :set_identity do
    $LOG.info('Setting up git identity...')
    continue
    system("git config --global user.name #{git_config_global_user_name}")
    system("git config --global user.email #{git_config_global_user_email}")
  end

  desc 'Set Git defaults'
  task :set_defaults do
    $LOG.info('Setting up git settings...')
    continue
    system("git config --global push.default #{git_config_global_push_default}")
    system("git config --global core.excludesfile #{git_config_global_core_excludesfile}")
    system('git config --global include.path .gitaliases')
  end
end

namespace :config do
  desc 'Set mischellaneous configs'
  task :all => [:mac_defaults, :setup_ssh_keys]

  task :setup_dropbox do
    $LOG.info('Login to Dropbox now and wait for the folder to sync...')
    continue
  end

  task :mac_defaults do
    $LOG.info('Setting up Mac defaults. This will require your password...')
    continue
    system('./configs/defaults_mac.sh')
  end

  task :setup_ssh_keys do
    unless File.exists?("#{ENV["HOME"]}/.ssh/id_rsa.pub")
      $LOG.info('Generating SSH keys...')
      system('ssh-keygen -o -t rsa -b 4096')
    end
  end
end

