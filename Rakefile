require 'io/console'
require 'logger'
$LOG = Logger.new(STDOUT)

#TODO: Steps requiring separate action should wait on input(e.g Alfred powerpack , fonts config, etc.)

homebrew_version="4.5.2"

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
    unless Dir["/opt/homebrew"].any?
      $LOG.info('Downloading Homebrew...')
      system("curl -o /tmp/homebrew-installer.pkg https://github.com/Homebrew/brew/releases/download/#{homebrew_version}/Homebrew-#{homebrew_version}.pkg")
      $LOG.info('Installing Homebrew...')
      system('sudo installer -verbose -pkg /tmp/homebrew-installer.pkg -target /')
    end
    continue
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
  task :all => [:mac_defaults, :setup_ssh_keys, :setup_icloud_folder]

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
    unless Dir["#{ENV["HOME"]}/.ssh/id_*.pub"].any?
      $LOG.info('Generating SSH keys...')
      system('ssh-keygen -t ed25519')
    end
  end

  task :setup_fonts do
    $LOG.info('Adding custom fonts...')
    continue
    system('cp ~/Dropbox/Fonts/* ~/Library/Fonts/')
  end

  task :setup_icloud_folder do
    unless Dir.exists?("#{ENV["HOME"]}/iCloud")
      $LOG.info('Linking iCloud folder into home directory...')
      system("ln -s \"#{ENV["HOME"]}/Library/Mobile\ Documents/com~apple~CloudDocs/\" #{ENV["HOME"]}/iCloud")
    end
  end
end

