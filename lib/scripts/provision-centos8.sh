#!/bin/sh

yum install -y epel-release
yum install -y vim htop rsync
yum install -y gcc-c++
sudo echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant-ssh