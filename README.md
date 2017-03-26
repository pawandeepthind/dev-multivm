# What
A bootstrap to setup connected multi-vm dev environment with pre-required software based on vagrant and ansible. Topology of multiple virtual machine consist of one management server with ansible installed and other machines in the topology is defined using configuration with only one command ``` vagrant up ```.

This brings up the machine with ssh keys setup, required software installed using provisioner ansible in management server.

# How

## 1. Install Pre-requisite:
  * [vagrant](https://releases.hashicorp.com/vagrant/1.9.1/) (tested with vagrant 1.9.1)
  * [Virtual Box](https://www.virtualbox.org/wiki/Download_Old_Builds_5_1) (tested with VirtualBox 5.1.10 r112026)
  * Software is installed in the machines using [ansible](https://www.ansible.com/) that is installed on mgmt_server
  * Install plugins
    ```$ vagrant plugin install vagrant-vbguest ```
    ```$ vagrant plugin install vagrant-hostmanager ```

## 2. Setup Config.yml as per requirement

```yml
---
mgmt_server: # server used for installing ansible provision
  name: mgmt1 # name of management server
  box: bento/centos-7.2 #which machine to use to setup base machine
  memory: 256
  ip: 10.0.20.10
  synced_folders: # array of folders to be shared between host and gues OS
    - { guest: "./server", host: "/home/vagrant/server" }
  forwarded_ports: # array of port to be mapped between host and gues OS
    - { guest: 1521, host: 1521 }
groups:
  - group_name: oracle_group # group name where we can define one or more servers
    servers: #array of servers that needs to be configured in this group
      - name: oracle
        box: bento/centos-7.2
        memory: 512
        ip: 10.0.20.20
        synced_folders: 
          - { guest: "./server", host: "/home/vagrant/server" }
        forwarded_ports:
          - { guest: 1521, host: 1521 }
  - group_name: activemq_group
    servers:
      - name: activemq
        box: bento/centos-7.2
        memory: 512
        ip: 10.0.20.30
        synced_folders: 
          - { guest: "./server", host: "/home/vagrant/server" }
        forwarded_ports:
          - { guest: 61616, host: 8616 }
          - { guest: 8161, host: 8161 }

```

## 3. Install required roles 
Install server/roles folder and update setup.yml to setup the roles that should be applied on the groups.
