# What

Project to setup multi-vm development environment (replicate production locally) with pre-required software installed on the machines. This setup uses
  * vagrant
  * virtual box as the provider
  * Ansible to orchestrate installation of software
  
  Topology for multiple virtual machine consist of:

  * One management server where ansible is installed when machine is provisioned. (Note: This machine is the last machine, and only one in the group in config.yml and is of type master)
  * Other machines in the topology is defined using configuration 

User can bring up the machine with one command ``` vagrant up ```.

This brings up multi-vm development environments with 
  * Connected machines.
  * Public/Private keys setup for password less access
  * Ansible installed on master machine, that will trigger setup.yml
  * setup.yml can be used to setup what roles to apply on which machine or group of machine.

# How

## 1. Install Pre-requisite:

It is good to read about Vagrant and Ansible.

## Here are some of the pre-requisite (Note: It is tested on Mac OS X for now)

  * vagrant (tested with vagrant 1.9.7)
  * Virtual Box (tested with VirtualBox 5.1.26r117224)
  * Software is installed in the machines using [ansible](https://www.ansible.com/) that is installed on mgmt_server
  * Install plugins (vbguest and hostmanager)
    
  ```
  $ vagrant plugin install vagrant-vbguest
  $ vagrant plugin install vagrant-hostmanager
  ```

## 2. config.yml configurations

```yml
---
groups: # root for multi-vm configuration
  - group_name: oracle_group # group name where we can define one or more servers
    servers: #array of servers that needs to be configured in this group
      - name: oracle # name of the server
        type: slave # type of the server (slave or masster), note: there needs to be one machine of type master 
                    # and others should be slave. And master machine should be in the end and that gorup should have only one machine
        box: centos/7 # which vagrant box to use to setup base machine
        memory: 512 # memory that should be given to the machine
        ip: 10.0.20.20 # ip address that should be given to the machine
        synced_folders: # list of folders to setup the sync
          - { guest: "./server", host: "/home/vagrant/server" }
        forwarded_ports: # list of ports to be forwarded from the guest to host
          - { guest: 1521, host: 1521 }
  - group_name: activemq_group
    servers:
      - name: activemq
        type: slave
        box: centos/7
        memory: 512
        ip: 10.0.20.30
        synced_folders: 
          - { guest: "./server", host: "/home/vagrant/server" }
        forwarded_ports:
          - { guest: 61616, host: 8616 }
          - { guest: 8161, host: 8161 }
  - group_name: management_server 
    servers:
      - name: mgmt
        type: master
        box: centos/7
        memory: 256
        ip: 10.0.20.10
        synced_folders: 
          - { guest: "./server", host: "/home/vagrant/server" }
        forwarded_ports:
```

# 3. Install required roles 

Install server/roles folder and update setup.yml to setup the roles that should be applied on the groups.
