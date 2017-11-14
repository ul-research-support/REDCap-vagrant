vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-triggers
vagrant up
vagrant halt
SET HDD_UUID=`C:\Whatever\VBoxManage.exe showvminfo redcap-secure | findstr 'SATA.*UUID' | replace `
SET USERNAME='redcap_user'