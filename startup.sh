#!/bin/bash
# You must install the Oracle VM VirtualBox Extension Pack for drive encryption
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-triggers
vagrant up
vagrant halt
HDD_UUID=`VBoxManage showvminfo redcap-secure | grep 'SATA.*UUID' | sed 's/^.*UUID: \(.*\))/\1/'`
USERNAME="redcap_user"
VBoxManage encryptmedium $HDD_UUID --newpassword - --newpasswordid $USERNAME --cipher "AES-XTS256-PLAIN64"
echo $USERNAME > .password_id
vagrant up
vagrant ssh -c 'sudo mkdir -p /etc/puppet/modules'
vagrant ssh -c 'sudo puppet module install puppetlabs/stdlib'
vagrant ssh -c 'sudo puppet apply /vagrant/manifests/manifest.pp'
