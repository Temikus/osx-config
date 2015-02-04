# Install frequently used mac applications

define app_deploy_dmg($sourcedir = false)
{
  $sourcedir_real = $sourcedir ? {
    false => "http://puppet.reductivelabs.foo/osx/pkgs/apps",
    default => $sourcedir
  }
  package { $name:
    ensure => installed,
    provider => appdmg,
    source => "$sourcedir_real/$name"
  }
}

define app_deploy_pkg($sourcedir = false)
{
  $sourcedir_real = $sourcedir ? {
    false => "http://puppet.reductivelabs.foo/osx/pkgs/apps",
    default => $sourcedir
  }
  package { $name:
    ensure => installed,
    provider => pkgdmg,
    source => "$sourcedir_real/$name"
  }
}


#####################################################################
#TODO: Fix appzip provider
#####################################################################

define app_deploy_appzip($sourcedir = false)
{
  $sourcedir_real = $sourcedir ? {
    false => "http://puppet.reductivelabs.foo/osx/pkgs/apps",
    default => $sourcedir
  }
  package { $name:
    ensure => installed,
    provider => appzip,
    source => "$sourcedir_real/$name"
  }
}

app_deploy_appzip { "colloquy-latest.zip":
            sourcedir => "http://colloquy.info/downloads",
            alias => colloquy
          }

#####################################################################

# Example
#
# app_deploy_dmg { "Firefox%2034.0.5.dmg":
#             sourcedir => "https://download-installer.cdn.mozilla.net/pub/firefox/releases/34.0.5/mac/en-US",
#             alias => firefox
#           }

app_deploy_dmg { "TextExpander.dmg":
            sourcedir => "https://dl.dropboxusercontent.com/u/334637/Software",
            alias => textexpander
          }

app_deploy_dmg { "SourceTree_2.0.4.dmg":
            sourcedir => "http://downloads.atlassian.com/software/sourcetree",
            alias => sourcetree }

app_deploy_dmg { "GoogleChrome.dmg":
            sourcedir => "https://dl.google.com/chrome/mac/dev",
            alias => googlechrome }

app_deploy_dmg { "Sublime%20Text%20Build%203065.dmg":
            sourcedir => "http://c758482.r82.cf2.rackcdn.com",
            alias => sublimetext }

app_deploy_dmg { "installgoogledrive.dmg":
            sourcedir => "https://dl.google.com/drive",
            alias => installgoogledrive }
