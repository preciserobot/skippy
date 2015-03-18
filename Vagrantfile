# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # FOLDERS
  config.vm.synced_folder "~", "/vagrant"  # NORMAL SHARE AS NFS HAS DELAYS
  config.vm.synced_folder ".", "/moldev"  # NORMAL SHARE AS NFS HAS DELAYS
  config.vm.synced_folder "./WORK", "/work", type: "nfs"  # the folder downloaded resources go to and where the results are stored

  # proxy config (CNTLM)
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "http://localhost:3128/"
    config.proxy.https    = "http://localhost:3128/"
    config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"
  end

  # PROXYBOX (to run behind proxy)
  config.vm.define "proxybox" do |proxybox|
    proxybox.vm.box_check_update = false
    proxybox.vm.box = "ubuntu/trusty64"
    proxybox.vm.hostname = "proxybox.molpath"
    proxybox.vm.network "private_network", ip: "192.168.33.22"
    proxybox.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "proxybox"
      vb.memory = "1024"
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
    end
    if Vagrant.has_plugin?("vagrant-proxyconf")
      config.env_proxy.http = "http://10.0.2.2:3128"  
      config.env_proxy.https = "http://10.0.2.2:3128"  
      config.proxy.http     = "http://10.0.2.2:3128"  
      config.proxy.https    = "http://10.0.2.2:3128"  
      config.proxy.no_proxy = "localhost,127.0.0.1,192.168.33.*"
    end
    proxybox.vm.provision "shell", path: "./vagrant/provision/proxybox.sh",args: ["/usr/local/pipeline", "/home/vagrant/.bashrc"]
  end

  # BASIC
  config.vm.define "basic" do |basic|
    basic.vm.box_check_update = false
    basic.vm.box = "ubuntu/trusty64"
    basic.vm.hostname = "basic.molpath"
    basic.vm.network "private_network", ip: "192.168.33.10"
    basic.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "basic"
      vb.memory = "1024"
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
    end
    basic.vm.provision "shell", path: "./vagrant/provision/base.sh"  # base configuration
  end

  # DOCKERBOX
  config.vm.define "dockerbox" do |dockerbox|
    dockerbox.vm.box_check_update = false
    dockerbox.vm.box = "ubuntu/trusty64"
    dockerbox.vm.hostname = "dockerbox.molpath"
    dockerbox.vm.network "private_network", ip: "192.168.33.11"
    dockerbox.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "dockerbox"
      vb.memory = "2048"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
    end
    dockerbox.vm.provision "shell", path: "./vagrant/provision/docker.sh"  # base configuration
  end

  # MASTER
  config.vm.define "master" do |master|
    master.vm.box = "ubuntu/trusty64"
    master.vm.hostname = "master.molpath"
    master.vm.network "private_network", ip: "192.168.33.12"
    master.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "moldev"
      # 1/2 memory & all cpu cores
      host = RbConfig::CONFIG['host_os']
      if host =~ /darwin/
        vb.cpus = `sysctl -n hw.ncpu`.to_i
        vb.memory = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2
      elsif host =~ /linux/
        vb.cpus = `nproc`.to_i
        vb.memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 2
      else # sorry Windows folks, I can't help you
        vb.cpus = 4
        vb.memory = 8192
      end
    end
    # PROVISIONING
    master.vm.provision "shell", path: "./vagrant/provision/base.sh"  # base install and dotfile import
    master.vm.provision "shell", path: "./vagrant/provision/dbserver.sh"  # SQL server
    master.vm.provision "shell", path: "./vagrant/provision/master.sh", args: ["/usr/local/pipeline", "/home/vagrant/.bashrc"]
    #master.vm.provision "shell", path: "./vagrant/provision/molpipe_resources.sh", args: ["/usr/local/pipeline", "/home/vagrant/.bashrc", "/work"]
  end

  # GRIDENGINE HEADNODE
  config.vm.define "headnode" do |headnode|
    headnode.vm.box_check_update = false
    headnode.vm.box = "ubuntu/trusty64"
    headnode.vm.hostname = "headnode.molpath"
    headnode.vm.network "private_network", ip: "192.168.33.13"
    headnode.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "headnode"
      vb.memory = "2048"
      vb.cpus = 1
      #vb.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
    end
    headnode.vm.provision "shell", path: "./vagrant/provision/base.sh"
    headnode.vm.provision "shell", path: "./vagrant/provision/gridengine_master.sh"
  end
  config.vm.define "node1" do |node1|
    node1.vm.box_check_update = false
    node1.vm.box = "ubuntu/trusty64"
    node1.vm.hostname = "node1.molpath"
    node1.vm.network "private_network", ip: "192.168.33.14"
    node1.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "node1"
      vb.memory = "2048"
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
    end
    node1.vm.provision "shell", path: "./vagrant/provision/base.sh"
    node1.vm.provision "shell", path: "./vagrant/provision/gridengine_execd.sh"
  end

  # DATABASE/WEB SERVER
  config.vm.define "dbserver" do |dbserver|
    dbserver.vm.box_check_update = false
    dbserver.vm.box = "ubuntu/trusty64"
    dbserver.vm.hostname = "dbserver.molpath"
    dbserver.vm.network "private_network", ip: "192.168.33.33"
    dbserver.vm.network "forwarded_port", guest: 80, host: 8080
    dbserver.vm.network "forwarded_port", guest: 3306, host: 3306
    #dbserver.vm.network "public_network"
    dbserver.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "dbserver"
      vb.memory = "1024"
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
    end
    dbserver.vm.provision "shell", path: "./vagrant/provision/base.sh"  # base configuration
    dbserver.vm.provision "shell", path: "./vagrant/provision/dbserver.sh"  # SQL server
    dbserver.vm.provision "shell", path: "./vagrant/provision/webserver.sh"  # WEB server
  end

  # CONFIG/REPO
  config.push.define "atlas" do |push|
    push.app = "molpath/pEasy"
  end

end
