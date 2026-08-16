require 'io/console'
require 'logger'
require 'json'
require 'fileutils'
require 'shellwords'

$LOG = Logger.new(STDOUT)

#TODO: Steps requiring separate action should wait on input(e.g Alfred powerpack , fonts config, etc.)

homebrew_version="4.5.2"

# Dotfiles settings
# osx-config normally lives at ~/.dotfiles/osx-config, so prefer the parent dir when it
# holds a Brewfile. DOTFILES_PATH overrides for standalone clones.
dotfiles_path = ENV.fetch('DOTFILES_PATH') do
  parent = File.expand_path('..', __dir__)
  File.exist?(File.join(parent, 'Brewfile')) ? parent : File.join(Dir.home, '.dotfiles')
end

# Git settings
git_config_global_user_name='Artem Yakimenko'
git_config_global_user_email='code@temik.me'
git_config_global_push_default='simple'
git_config_global_core_excludesfile='~/.gitignore_global'

default_homebrew_prefix = '/opt/homebrew'

BAIL_EXIT_STATUS = 143 # 128 + SIGTERM

$bail_requested = false
$critical_section = nil

# Bail on SIGTERM, but only between steps: exiting while an installer or a sudo
# prompt is mid-flight would leave a half-written system behind. Inside a critical
# section we just record the request and let `critical` act on it once the step ends.
Signal.trap('TERM') do
  $bail_requested = true
  bail_now! unless $critical_section
end

# Called from a trap handler, so no $LOG here: Logger takes a mutex and would
# deadlock if the signal landed mid-log. getch leaves the tty in raw mode, so
# restore it before exiting or the caller's shell is left unusable.
def bail_now!
  STDIN.cooked! if STDIN.tty?
  warn "\nSIGTERM received, bailing out."
  exit!(BAIL_EXIT_STATUS)
end

# Bail here if a SIGTERM arrived while we were busy.
def checkpoint
  bail_now! if $bail_requested
end

# Wrap a step that must not be interrupted half-way.
def critical(description)
  $critical_section = description
  yield
ensure
  $critical_section = nil
  checkpoint
end

# Helper module
def continue(message = nil)
  checkpoint
  puts "#{message}" if message
  print 'Press any key to continue...'
  STDIN.getch
  print "            \r" # extra space to overwrite in case next sentence is short
end

# Path to an existing brew binary, or nil. Checks PATH first, then the standard prefixes.
def brew_path
  on_path = `command -v brew 2>/dev/null`.strip
  return on_path unless on_path.empty?

  ['/opt/homebrew/bin/brew', '/usr/local/bin/brew'].find { |brew| File.executable?(brew) }
end

# Active developer dir per xcode-select, or nil when unset or pointing at a missing dir.
def xcode_developer_dir
  dir = `xcode-select --print-path 2>/dev/null`.strip
  return nil if dir.empty? || !Dir.exist?(dir)

  dir
end

# Only full Xcode carries a license agreement, CLI tools on their own don't.
def full_xcode_selected?
  dir = xcode_developer_dir
  !dir.nil? && dir.end_with?('.app/Contents/Developer')
end

# xcodebuild exits non-zero and complains until the license has been accepted.
def xcode_license_accepted?
  `xcodebuild -version > /dev/null 2>&1`
  $?.success?
end

def prompt_yes_no(question, default: false)
  print "#{question} #{default ? '[Y/n]' : '[y/N]'}: "
  answer = STDIN.gets.to_s.chomp.strip.downcase
  return default if answer.empty?

  %w[y yes].include?(answer)
end

#desc 'Install the whole shebang'
task :install => [:'preinstall:all',
                  :'homebrew:install',
                  :'config:all',
                  :'git:configure']

namespace :preinstall do

  desc 'Run all preinstall tasks'
  task :all => [:xcode_select]

  desc 'Install Xcode CLI tools'
  task :xcode_select do
    developer_dir = xcode_developer_dir

    if developer_dir
      $LOG.info("Xcode CLI tools already installed (#{developer_dir}), skipping install...")
    else
      $LOG.info('Installing Xcode CLI tools...')
      critical('Xcode CLI tools install') { system('xcode-select --install') }
      continue
    end

    unless full_xcode_selected?
      $LOG.info('Full Xcode not selected, skipping license agreement.')
      next
    end

    if xcode_license_accepted?
      $LOG.info('Xcode license already accepted, skipping...')
      next
    end

    $LOG.info('Accepting the Xcode license agreement. This will require your password...')
    continue
    critical('Xcode license agreement') { system('sudo xcodebuild -license') }
  end
end

namespace :homebrew do

  desc 'Install Homebrew, Cask and packages'
  task :install => [:install_homebrew, :install_homebrew_packages]

  desc 'Install Homebrew'
  task :install_homebrew do
    existing_brew = brew_path

    if existing_brew
      $LOG.info("Homebrew already installed at #{existing_brew}, skipping install...")
      next
    end

    if prompt_yes_no("Install Homebrew into a prefix other than #{default_homebrew_prefix}?")
      print 'Prefix: '
      prefix = File.expand_path(STDIN.gets.to_s.chomp.strip)

      $LOG.warn("Non-standard prefixes are unsupported by Homebrew: no bottles, everything builds from source.")
      $LOG.info("Installing Homebrew #{homebrew_version} into #{prefix}...")
      FileUtils.mkdir_p(prefix)
      critical('Homebrew tarball unpack') do
        system("curl -fsSL https://github.com/Homebrew/brew/tarball/#{homebrew_version} | tar xz --strip 1 -C #{prefix.shellescape}")
      end
      # Make the fresh brew visible to the rest of this rake run
      ENV['PATH'] = "#{prefix}/bin:#{ENV['PATH']}"
      $LOG.info("Done. Add #{prefix}/bin to your PATH, e.g. eval \"$(#{prefix}/bin/brew shellenv)\"")
    else
      $LOG.info('Downloading Homebrew...')
      system("curl -o /tmp/homebrew-installer.pkg https://github.com/Homebrew/brew/releases/download/#{homebrew_version}/Homebrew-#{homebrew_version}.pkg")
      checkpoint # download is resumable, so a bail here is free
      $LOG.info('Installing Homebrew...')
      critical('Homebrew pkg install') { system('sudo installer -verbose -pkg /tmp/homebrew-installer.pkg -target /') }
    end

    continue
  end

  desc 'Install Homebrew packages'
  task :install_homebrew_packages do
    brew = brew_path
    unless brew
      $LOG.error('Cannot find brew, skipping package install.')
      next
    end

    unless File.exist?(File.join(dotfiles_path, 'Brewfile'))
      $LOG.error("No Brewfile in #{dotfiles_path}, skipping package install. Set DOTFILES_PATH to override.")
      next
    end

    $LOG.info("Installing Homebrew packages from #{dotfiles_path}/Brewfile...")
    continue

    Dir.chdir(dotfiles_path){
      critical('brew bundle') { system("#{brew.shellescape} bundle") }
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
    critical('git identity') do
      system("git config --global user.name #{git_config_global_user_name}")
      system("git config --global user.email #{git_config_global_user_email}")
    end
  end

  desc 'Set Git defaults'
  task :set_defaults do
    $LOG.info('Setting up git settings...')
    continue
    critical('git defaults') do
      system("git config --global push.default #{git_config_global_push_default}")
      system("git config --global core.excludesfile #{git_config_global_core_excludesfile}")
      system('git config --global include.path .gitaliases')
    end
  end
end

namespace :config do
  desc 'Set mischellaneous configs'
  task :all => [:setup_dropbox, :mac_defaults, :setup_ssh_keys, :setup_fonts, :setup_icloud_folder]

  task :setup_dropbox do
    $LOG.info('Login to Dropbox now and wait for the folder to sync...')
    continue
  end

  task :mac_defaults do
    $LOG.info('Setting up Mac defaults. This will require your password...')
    continue
    critical('Mac defaults') { system('./configs/defaults_mac.sh') }
  end

  task :setup_ssh_keys do
    unless Dir["#{ENV["HOME"]}/.ssh/id_*.pub"].any?
      $LOG.info('Generating SSH keys...')
      continue
      critical('ssh-keygen') { system('ssh-keygen -t ed25519') }
    end
  end

  task :setup_fonts do
    $LOG.info('Adding custom fonts...')
    continue
    critical('font copy') { system('cp ~/Dropbox/Fonts/* ~/Library/Fonts/') }
  end

  task :setup_icloud_folder do
    $LOG.info('Setting up iCloud folder...')
    continue
    unless Dir.exists?("#{ENV["HOME"]}/iCloud")
      $LOG.info('Linking iCloud folder into home directory...')
      critical('iCloud symlink') do
        system("ln -s \"#{ENV["HOME"]}/Library/Mobile\ Documents/com~apple~CloudDocs/\" #{ENV["HOME"]}/iCloud")
      end
    end
  end

  task :configure_claude do |t|
    $LOG.info('Configuring Claude...')
    continue

    claude_config_dir = "#{ENV["HOME"]}/Library/Application Support/Claude"
    claude_config_file = "#{claude_config_dir}/claude_desktop_config.json"
    dropbox_config_file = "#{ENV["HOME"]}/Dropbox/Apps/Claude/claude_desktop_config.json"

    if File.exist?(claude_config_file)
      begin
        config_data = JSON.parse(File.read(claude_config_file))
        if !config_data.has_key?('mcpServers') || config_data['mcpServers'].empty?
          $LOG.info('Local config not populated, installing custom config...')
          critical('Claude config copy') { FileUtils.cp(dropbox_config_file, claude_config_file) }
        else
          $LOG.info('Local config found, comparing...')
          dropbox_config_data = JSON.parse(File.read(dropbox_config_file))
          if config_data != dropbox_config_data
            $LOG.info('Local Claude config differs from Dropbox config.')
            print 'Would you like to replace the local config with the Dropbox version? (y/n): '
            if STDIN.gets.chomp.downcase == 'y'
              critical('Claude config copy') { FileUtils.cp(dropbox_config_file, claude_config_file) }
              $LOG.info('Claude config replaced successfully.')
            else
              $LOG.info('Keeping local Claude config.')
            end
          else
            $LOG.info('Claude configs are identical, no action needed.')
          end
        end
      rescue JSON::ParserError => e
        $LOG.warn("Error parsing Claude config: #{e}")
        $LOG.info('Bailing out...')
      end
    else
      $LOG.info('Cannot find Claude settings folder...')
    end
  end
end
