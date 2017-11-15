PATH=%PATH%;C:\"Program Files"\Oracle\VirtualBox
@echo off
set /p HOST_USERNAME="Enter your Windows username:"
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-triggers
vagrant up
vagrant halt
powershell -command "cat \"C:\Users\%HOST_USERNAME%\VirtualBox VMs\redcap-secure\redcap-secure.vbox\" | findstr /l \"HardDisk uuid=\""
@echo off
set /p HDD_UUID="Enter Hard Disk UUID - NOT MACHINE UUID: "
SET USERNAME="redcap_user"
VBoxManage encryptmedium %HDD_UUID% --newpassword - --newpasswordid %USERNAME% --cipher "AES-XTS256-PLAIN64"
ECHO %USERNAME% > .password_id
vagrant up
vagrant ssh -c 'sudo mkdir -p /etc/puppet/modules'
vagrant ssh -c 'sudo puppet module install puppetlabs/stdlib'
vagrant ssh -c 'sudo puppet apply /vagrant/manifests/manifest.pp'