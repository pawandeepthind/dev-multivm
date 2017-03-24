# Defines our Vagrant environment
#
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version '>= 1.9.1'
VAGRANTFILE_API_VERSION = '2'.freeze

# Require YAML module
require 'yaml'

# Read YAML file with box details
groups = YAML.load_file('config.yml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false

  groups.each do |group|
    group['servers'].each do |server|
      config.vm.define server['name'] do |srv_config|
        srv_config.vm.box = server['box']
        srv_config.vm.hostname = server['name']

        # Forward oracle port
        srv_config.vm.network :private_network, ip: server['ip']

        server['forwarded_ports'].each do |port|
          srv_config.vm.network :forwarded_port,
                                guest: port['guest'],
                                host: port['host']
        end

        server['synced_folders'].each do |folder|
          srv_config.vm.synced_folder folder['guest'],
                                      folder['host'],
                                      create: true
        end

        # Provider-specific configuration so you can fine-tune various backing
        # providers for Vagrant. These expose provider-specific options.
        srv_config.vm.provider :virtualbox do |vb|
          # Use VBoxManage to customize the VM
          vb.customize ['modifyvm', :id,
                        '--name', server['name'],
                        '--memory', server['memory']]
        end
        if Vagrant::VERSION =~ /^1.9.1/
          srv_config.vm.provision :shell do |s|
            s.path = 'vag191workaround.sh'
          end
        end
      end
    end
  end

  # truncate the current bootstrap
  File.open('server/inventory.ini', 'w') do |f|
    f.write "mgmt          ansible_connection=local\n"
    groups.each do |group|
      group['servers'].each do |server|
        f.write "#{server['name']}            ansible_ssh_host=#{server['ip']} ansible_ssh_private_key_file=/vagrant/.vagrant/machines/#{server['name']}/virtualbox/private_key\n"
      end
    end

    groups.each do |group|
      f.write "[#{group['group_name']}]\n"
      group['servers'].each do |server|
        f.write "#{server['name']}\n"
      end
    end
  end

  # truncate the current bootstrap
  File.open('bootstrap-mgmt.sh', 'w') do |f|
    f.write "#!/usr/bin/env bash\n"
    f.write "su vagrant <<'EOF'\n"
    f.write "yes | ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''\n"
    serverlist = ''
    groups.each do |group|
      group['servers'].each do |server|
        serverlist += "#{server['name']} "
      end
    end
    f.write "ssh-keyscan #{serverlist} >> ~/.ssh/known_hosts\n"
    f.write "EOF\n"
  end

  # create mgmt machine
  config.vm.define :ctl do |ctl_config|
    ctl_config.vm.box = 'bento/centos-7.2'
    ctl_config.vm.hostname = 'ctl'
    ctl_config.vm.network :private_network, ip: '10.0.20.10'
    ctl_config.vm.synced_folder './server',
                                '/home/vagrant/server',
                                create: true
    ctl_config.vm.provider :virtualbox do |vb|
      # Use VBoxManage to customize the VM
      vb.customize ['modifyvm', :id,
                    '--name', 'ctl',
                    '--memory', '256']
    end
    if Vagrant::VERSION =~ /^1.9.1/
      ctl_config.vm.provision :shell do |s|
        s.path = 'vag191workaround.sh'
      end
    end
    ctl_config.vm.provision :shell, run: 'always' do |s|
      s.path = 'bootstrap-mgmt.sh'
    end
    ctl_config.vm.provision 'ansible_local', run: 'always' do |ansible|
      ansible.version = 'latest'
      ansible.provisioning_path = '/home/vagrant/server/'
      ansible.playbook = 'setup.yml'
      ansible.install = true
      ansible.install_mode = :pip
      ansible.sudo = true
      ansible.verbose = false
      ansible.limit = 'all'
      ansible.inventory_path = '/home/vagrant/server/inventory.ini'
    end

    ctl_config.ssh.insert_key = false
  end
end
