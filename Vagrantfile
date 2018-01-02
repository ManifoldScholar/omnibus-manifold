require 'vagrant'

# Hack to make it work
# See https://github.com/berkshelf/vagrant-berkshelf/issues/318
ENV["GEM_PATH"] = nil
ENV["GEM_HOME"] = nil

if Vagrant::VERSION < '1.2.1'
  raise "The Omnibus Build Lab is only compatible with Vagrant 1.2.1+"
end

VAGRANTFILE_API_VERSION = ?2

host_project_path   = File.expand_path('..', __FILE__)
guest_project_path  = "/home/vagrant/#{File.basename(host_project_path)}"
project_name        = 'manifold'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'bento/ubuntu-16.04'

  config.dns.tld = 'vagrant'

  config.vm.provider :virtualbox do |vb|
    vb.customize [
                     "modifyvm", :id,
                     "--memory", "3084",
                     "--cpus",   "2"
                 ]
  end

  config.vm.define "builder" do |builder|
    builder.dns.tld = 'vagrant'
    builder.vm.hostname = "build.omnibus-#{project_name}"
    builder.vm.provision :shell, path: 'lib/scripts/setup_install.sh'
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

    builder.vm.network :private_network, ip: '10.42.1.1'
  end

  config.vm.define "install" do |install|
    install.dns.tld = 'vagrant'

    install.vm.hostname = "install.omnibus-#{project_name}.vagrant"

    install.vm.provision :shell, path: 'lib/scripts/setup_install.sh'

    install.vm.network :private_network, ip: '10.42.2.2'
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

  config.vm.synced_folder host_project_path, guest_project_path, type: 'rsync', rsync__exclude: %w[.git/ local/]

  config.vm.network :private_network, type: 'dhcp'
end