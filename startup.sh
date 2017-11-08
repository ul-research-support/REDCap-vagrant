#!/bin/bash
# You must install the Oracle VM VirtualBox Extension Pack for drive encryption
vagrant plugin install vagrant-vbguest
vagrant plugin instal vagrant-triggers
vagrant up
vagrant suspend
HDD_UUID=`VBoxManage showvminfo redcap-secure | grep 'SATA.*UUID' | sed 's/^.*UUID: \(.*\))/\1/'`
USERNAME="redcap_user"
VBoxManage encryptmedium $HDD_UUID --newpassword - --newpasswordid $USERNAME --cipher "AES-XTS256-PLAIN64"
echo $USERNAME > .password_id
