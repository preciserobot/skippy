# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # FOLDERS
  config.vm.synced_folder ".", "/skippy", type: "nfs" 

  # skippy
  config.vm.define "skippy" do |skippy|
    skippy.vm.box_check_update = false
    skippy.vm.box = "ubuntu/trusty64"
    skippy.vm.hostname = "skippy.molpath"
    skippy.vm.network "private_network", ip: "192.168.33.21"
    skippy.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "skippy"
      vb.memory = "2048"
      vb.cpus = 4
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
    end
    skippy.vm.provision "docker" do |d|
	d.pull_images "mongo:3.1"
    end
  end

  # CONFIG/REPO
  config.push.define "atlas" do |push|
    push.app = "viapath/skippy"
  end

end
