PASSWORD_PATH = ".password"
PASSWORD_ID_PATH = ".password_id"

# You must install the Oracle VM VirtualBox Extension Pack for drive encryption
# Credit for drive encryption in Ruby goes to GitHub user gabrielelana
# Make sure to have installed vagrant-triggers plugin
# > vagrant plugin install vagrant-triggers
# After the first `vagrant up` stop the VM and execute the following steps
# Take the identifier of the storage you want to encrypt
# > HDD_UUID=`VBoxManage showvminfo <VM_NAME> | grep 'SATA.*UUID' | sed 's/^.*UUID: \(.*\))/\1/'`
# Store your usernname (whitespaces are not allowed) in a variable
# > USERNAME="<YOUR_USER_NAME_WITHOUT_WHITESPACES>"
# Encrypt the storage, enter the password when asked
# > VBoxManage encryptmedium $HDD_UUID --newpassword - --newpasswordid $USERNAME --cipher "AES-XTS256-PLAIN64"
# Store the username in a file named .password_id
# > echo $USERNAME > .password_id
# Now, the next time you start the VM you'll be asked for the same password

Vagrant.configure("2") do |config|

   config.vm.box = "ubuntu/trusty64"
   config.vm.box_check_update = false
   config.vm.hostname = "redcap-secure"
   config.trigger.before :up do
     if File.exists?(PASSWORD_ID_PATH)
       password_id = File.read(PASSWORD_ID_PATH).strip
       print "The VM is encrypted, please enter the password\n#{password_id}: "
       password = STDIN.noecho(&:gets).strip
       File.write(PASSWORD_PATH, password)
       puts ""
     end
   end

   config.trigger.after :up do
     File.delete(PASSWORD_PATH) if File.exists?(PASSWORD_PATH)
   end

   config.trigger.after :destroy do
     File.delete(PASSWORD_ID_PATH) if File.exists?(PASSWORD_ID_PATH)
   end

   config.vm.provider :virtualbox do |vb|
     vb.name = "redcap-secure"
     vb.gui = false

     if File.exists?(PASSWORD_ID_PATH)
       password_id = File.read(PASSWORD_ID_PATH).strip
       vb.customize "post-boot", [
         "controlvm", :id, "addencpassword", password_id, PASSWORD_PATH, "--removeonsuspend", "yes"
       ]
     end
   end

   if File.exists?(PASSWORD_ID_PATH)
     config.vm.network "forwarded_port", guest: 80, host: 1130
       config.vm.provision :shell do |shell|
          shell.inline = "sudo apt-get update -y
                          sudo apt-get upgrade -y
                          sudo mkdir -p /etc/puppet/modules
                          sudo puppet module install puppetlabs/stdlib
                          sudo apt-get install apache2 -y
                          sudo apt-get install unzip -y
                          sudo unzip /vagrant/redcap*.zip -d /var/www/html
                          cd /var/www/html/redcap*; r_v=${PWD##*/}; redcap_version=$(echo $r_v | awk -F\"p\" '{ print $2 }')
                          echo $redcap_version > /vagrant/rv.txt
                          cd /var/www/html
                          sudo cp -R /var/www/html/redcap${redcap_version}/redcap /var/www/html && rm -rf /var/www/html/redcap${redcap_version}
                          sudo puppet apply /vagrant/manifests/manifest.pp
                          redcap_version=$(cat /vagrant/rv.txt)
                          /usr/bin/mysql -u redcap_user -predcapDBpassword redcap -e \"UPDATE redcap_config SET value = '${redcap_version}' WHERE field_name = 'redcap_version' \""
        end
   end
end
