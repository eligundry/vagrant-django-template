# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

seed = [('a'..'z'), ('A'..'Z'), ('0'..'9'), '!@#$%^&*(-_=+)'.split(//)].map { |i| i.to_a  }.flatten
secrets = YAML.load_file('secrets.yml')

Vagrant.configure("2") do |config|
  # Base box to build off, and download URL for when it doesn't exist on the user's system already
  config.vm.box = "ubuntu/utopic64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/utopic/current/utopic-server-cloudimg-amd64-vagrant-disk1.box"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.network :forwarded_port, guest: 8000, host: 8111
  config.vm.network :forwarded_port, guest: 80, host: 8080

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  config.vm.synced_folder ".", "/home/vagrant/{{ project_name }}"

  config.vm.provider :virtualbox do |vb|
    vb.gui = false
    vb.memory = 1024
  end

  # Digital Ocean Provider Setup
  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

    provider.token = secrets["digital_ocean"]["token"]
    provider.image = "ubuntu-14-10-x64"
    provider.region = "nyc2"
    provider.size = "512mb"

    if secrets["digital_ocean"]["user"]
      override.ssh.username = secrets["digital_ocean"]["user"]
    end
  end

  # Enable provisioning with a shell script.
  config.vm.provision :shell, :path => "etc/install/install.sh", :args => [
    "{{ project_name }}",
    (0..50).map { seed[rand(seed.length)] }.join,
    (secrets["db"]["prod"]["pass"] or (0..30).map { seed[rand(seed.length)] }.join),
    (secrets["db"]["dev"]["pass"] or (0..30).map { seed[rand(seed.length)] }.join),
    (secrets["db"]["test"]["pass"] or (0..30).map { seed[rand(seed.length)] }.join),
  ]
end
