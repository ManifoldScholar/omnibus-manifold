require 'vagrant'

# Hack to make it work
# See https://github.com/berkshelf/vagrant-berkshelf/issues/318
ENV["GEM_PATH"] = nil
ENV["GEM_HOME"] = nil

if Vagrant::VERSION < '1.2.1'
  raise "The Omnibus Build Lab is only compatible with Vagrant 1.2.1+"
end

if Vagrant::VERSION < '2.0.0'
  raise "omnibus-manifold requires Vagrant 2.0.0+"
end

VIRTUALBOX_VERSION = %x[vboxmanage --version].to_s.strip[/\A(\d+\.\d+\.\d+)/, 1]

if VIRTUALBOX_VERSION < '5.2.0'
  raise "omnibus-manifold requires Virtualbox 5.2+ to build ubuntu 18 remotely"
end

VAGRANTFILE_API_VERSION = ?2

host_project_path   = File.expand_path('..', __FILE__)
guest_project_path  = "/vagrant"
project_name        = 'manifold'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.dns.tld = 'vagrant'

  config.vm.provider :virtualbox do |vb|
    vb.customize [
      "modifyvm", :id,
      "--memory", "3084",
      "--cpus",   "2",
      "--cableconnected0", "on",
      "--cableconnected1", "on",
    ]
  end

  config.vm.define 'ubuntu16-builder' do |builder|
    builder.vm.box = 'bento/ubuntu-16.04'
    builder.dns.tld = 'vagrant'
    builder.vm.hostname = "ubuntu16-builder.omnibus-#{project_name}"
    builder.vm.provision :chef_solo do |chef|
      chef.json = {
        "omnibus" => {
          "build_user"  => "vagrant",
          "build_dir"   => guest_project_path,
          "install_dir" => "/opt/#{project_name}"
        }
      }

      chef.run_list = [
        "recipe[omnibus::default]"
      ]
    end

    builder.vm.provision :shell, path: 'lib/scripts/provision-ubuntu-16.sh'

    builder.vm.network :private_network, ip: '10.42.1.2'
  end

  config.vm.define 'ubuntu16-install' do |install|
    install.vm.box = 'bento/ubuntu-16.04'

    install.dns.tld = 'vagrant'

    install.vm.hostname = "ubuntu16-install.omnibus-#{project_name}"

    install.vm.provision :shell, path: 'lib/scripts/provision-ubuntu-16.sh'

    install.vm.network :private_network, ip: '10.42.1.3'
  end

  config.vm.define 'centos7-builder' do |builder|
    builder.vm.box = 'bento/centos-7.5'

    builder.dns.tld = 'vagrant'

    builder.vm.hostname = "centos7-builder.omnibus-#{project_name}"

    builder.vm.provision :chef_solo do |chef|
      chef.json = {
        "omnibus" => {
          "build_user"  => "vagrant",
          "build_dir"   => guest_project_path,
          "install_dir" => "/opt/#{project_name}"
        }
      }

      chef.run_list = [
        "recipe[omnibus::default]"
      ]
    end

    builder.vm.provision :shell, path: 'lib/scripts/provision-centos-75.sh'

    builder.vm.network :private_network, ip: '10.42.1.4'
  end

  config.vm.define 'centos7-install' do |install|
    install.vm.box = 'bento/centos-7.5'

    install.dns.tld = 'vagrant'

    install.vm.hostname = "centos7-install.omnibus-#{project_name}"

    install.vm.provision :shell, path: 'lib/scripts/provision-centos-75.sh'

    install.vm.network :private_network, ip: '10.42.1.5'
  end

  config.vm.define 'ubuntu18-builder' do |builder|
    builder.vm.box = 'bento/ubuntu-18.04'

    builder.dns.tld = 'vagrant'

    builder.vm.hostname = "ubuntu18-builder.omnibus-#{project_name}"

    builder.vm.provision :chef_solo do |chef|
      chef.json = {
        "omnibus" => {
          "build_user"  => "vagrant",
          "build_dir"   => guest_project_path,
          "install_dir" => "/opt/#{project_name}"
        }
      }

      chef.run_list = [
        "recipe[omnibus::default]"
      ]
    end

    builder.vm.provision :shell, path: 'lib/scripts/provision-ubuntu-18.sh'

    builder.vm.network :private_network, ip: '10.42.1.6'
  end

  config.vm.define 'ubuntu18-install' do |install|
    install.vm.box = 'bento/ubuntu-18.04'

    config.vm.provider :virtualbox do |vb|
      vb.memory = 4096
    end

    install.dns.tld = 'vagrant'

    install.vm.hostname = "ubuntu18-install.omnibus-#{project_name}"

    install.vm.provision :shell, path: 'lib/scripts/provision-ubuntu-18.sh'

    install.vm.network :private_network, ip: '10.42.1.7'
  end

  config.omnibus.chef_version = :latest

  # Enable the berkshelf-vagrant plugin
  config.berkshelf.enabled    = true

  # The path to the Berksfile to use with Vagrant Berkshelf
  config.berkshelf.berksfile_path = './Berksfile'

  # Disable vagrant-vbguest to update VirtualBox Guest Additions
  # config.vbguest.auto_update = false

  # config.ssh.max_tries      = 40
  # config.ssh.timeout        = 120
  config.ssh.forward_agent  = true

  config.vm.network :private_network, type: 'dhcp'
end
