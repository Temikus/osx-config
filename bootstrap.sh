#!/bin/bash

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

install_packages()
{
sudo puppet apply --debug --modulepath=./modules appinstall.pp
}

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

install_packages


