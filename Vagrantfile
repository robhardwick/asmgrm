# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

$script = <<'SCRIPT'
PACKAGES="curl vim git screen nginx spawn-fcgi build-essential nasm make libfcgi-dev"

# Install packages
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -o Dpkg::Options::="--force-confnew" upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install $PACKAGES

# Set nginx config
sudo cp conf/nginx.conf /etc/nginx/sites-available/default

# Build and run
cd /vagrant
make
sudo make run
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    config.vm.network "forwarded_port", guest: 80, host: 8888
    config.vm.provision 'shell', inline: $script, privileged: false
end
