PATH=%PATH%;C:\"Program Files"\Oracle\VirtualBox
@echo off
set /p HOST_USERNAME="Enter your Windows username:"
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-triggers
vagrant up
vagrant halt
powershell -command "cat C:/Users/%HOST_USERNAME%/'VirtualBox VMs'/redcap-secure/redcap-secure.vbox" | findstr /l "<Image uuid="
@echo off
set /p HDD_UUID="Enter Hard Disk UUID - not Machine uuid: "
SET USERNAME="redcap_user"
VBoxManage encryptmedium %HDD_UUID% --newpassword - --newpasswordid %USERNAME% --cipher "AES-XTS256-PLAIN64"
ECHO %USERNAME% > .password_id
vagrant up
