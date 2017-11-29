PASSWORD_PATH = ".password"
PASSWORD_ID_PATH = ".password_id"
HDD_UUID = ".hdd_uuid"

# You must install the Oracle VM VirtualBox Extension Pack for drive encryption
# Credit for drive encryption in Ruby goes to GitHub user gabrielelana

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
         "controlvm", "redcap-secure", "addencpassword", password_id, PASSWORD_PATH, "--removeonsuspend", "yes"
       ]
     end
   end

    config.vm.network "forwarded_port", guest: 80, host: 1130
    config.vm.provision :shell do |shell|
      shell.inline = "sudo apt-get update -y
                      sudo apt-get upgrade -y
                      sudo mkdir -p /etc/puppet/modules
                      sudo puppet module install puppetlabs/stdlib
                      sudo apt-get install apache2 -y
                      sudo apt-get install unzip -y
                      sudo unzip /vagrant/redcap*.zip -d /var/www/html
                      cd /var/www/html/redcap/redcap_v*; r_v=${PWD##*/}; redcap_version=$(echo $r_v | awk -F\"v\" '{ print $2 }')
                      echo $redcap_version > /vagrant/redcap-install/rv.txt
                      sudo puppet apply /vagrant/redcap-install/scripts/manifest.pp
                      redcap_version=$(cat /vagrant/redcap-install/rv.txt)
                      /usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /var/www/html/redcap/redcap_v${redcap_version}/Resources/sql/install.sql
                      /usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /var/www/html/redcap/redcap_v${redcap_version}/Resources/sql/install_data.sql
                      /usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /vagrant/redcap-install/scripts/redcap_extras.sql
                      rm -rf /vagrant/redcap-install/rv.txt"
    end
end


