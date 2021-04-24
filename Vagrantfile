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

  config.omnibus.install_url = "https://omnitruck.chef.io/install.sh"
  config.omnibus.chef_version = :latest

  config.vm.provider :virtualbox do |vb|
    vb.customize [
      "modifyvm", :id,
      "--memory", "3084",
      "--cpus",   "2",
      "--cableconnected0", "on",
      "--cableconnected1", "on",
    ]
  end

  platforms = [
    { name: "ubuntu16", box: 'bento/ubuntu-16.04', builder_ip: '10.42.1.2', installer_ip: '10.42.1.3' },
    { name: "centos7", box: 'bento/centos-7.9', builder_ip: '10.42.1.4', installer_ip: '10.42.1.5' },
    { name: "ubuntu18", box: 'bento/ubuntu-18.04', builder_ip: '10.42.1.6', installer_ip: '10.42.1.7' },
    { name: "ubuntu20", box: 'bento/ubuntu-20.04', builder_ip: '10.42.1.8', installer_ip: '10.42.1.9' },
    { name: "centos8", box: 'bento/centos-8.3', builder_ip: '10.42.1.10', installer_ip: '10.42.1.11' },
  ]

  platforms.each do |platform|

    # Define builder
    config.vm.define "#{platform[:name]}-builder" do |builder|
      builder.vm.box = platform[:box]
      builder.dns.tld = 'vagrant'
      builder.vm.hostname = "#{platform[:name]}-builder.omnibus-#{project_name}"
      builder.vm.provision :shell, path: "lib/scripts/provision-#{platform[:name]}.sh"
      builder.vm.provision :chef_solo do |chef|
        chef.custom_config_path = "CustomConfiguration.chef"
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

      builder.vm.network :private_network, ip: platform[:builder_ip]
    end

    # Define installer
    config.vm.define "#{platform[:name]}-install" do |install|
      install.vm.box = platform[:box]
      install.dns.tld = 'vagrant'
      install.vm.hostname = "#{platform[:name]}-install.omnibus-#{project_name}"
      install.vm.provision :shell, path: "lib/scripts/provision-#{platform[:name]}.sh"
      install.vm.network :private_network, ip: platform[:installer_ip]
    end

  end

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
