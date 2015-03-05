# -*- mode: ruby -*-
# vi: set ft=ruby :

seed = [('a'..'z'), ('A'..'Z'), ('0'..'9'), '!@#$%^&*(-_=+)'.split(//)].map { |i| i.to_a  }.flatten

Vagrant.configure("2") do |config|
	# Base box to build off, and download URL for when it doesn't exist on the user's system already
	config.vm.box = "ubuntu/utopic64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/utopic/current/utopic-server-cloudimg-amd64-vagrant-disk1.box"

	# Boot with a GUI so you can see the screen. (Default is headless)
	# config.vm.boot_mode = :gui

	# Assign this VM to a host only network IP, allowing you to access it
	# via the IP.
	# config.vm.network "33.33.33.10"

	# Forward a port from the guest to the host, which allows for outside
	# computers to access the VM, whereas host only networking does not.
  config.vm.network :forwarded_port, guest: 8000, host: 8111
  config.vm.network :forwarded_port, guest: 8080, host: 80

	# Share an additional folder to the guest VM. The first argument is
	# an identifier, the second is the path on the guest to mount the
	# folder, and the third is the path on the host to the actual folder.
  config.vm.synced_folder ".", "/home/vagrant/{{ project_name }}"

	# Enable provisioning with a shell script.
	config.vm.provision :shell, :path => "etc/install/install.sh", :args => [
	  "{{ project_name }}",
    (0..50).map { seed[rand(seed.length)] }.join,
    (0..30).map { seed[rand(seed.length)] }.join,
    (0..30).map { seed[rand(seed.length)] }.join,
    (0..30).map { seed[rand(seed.length)] }.join,
	]
end
