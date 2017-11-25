PASSWORD_PATH = ".password"
PASSWORD_ID_PATH = ".password_id"

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
         "controlvm", :id, "addencpassword", password_id, PASSWORD_PATH, "--removeonsuspend", "yes"
       ]
     end
   end

   # if File.exists?(PASSWORD_ID_PATH)
    config.vm.network "forwarded_port", guest: 80, host: 1130
    config.vm.provision "shell", path: "redcap-install/scripts/install.sh"
   # end
end
