
Vagrant.configure("2") do |config|
 
   config.vm.box = "ubuntu/trusty64"

   config.vm.synced_folder "../redcap7.0.11/redcap", "/tmp/vagrant/redcap"

   config.vm.synced_folder "../redcap7.0.11/redcap/redcap_v7.0.11/Resources/sql", "/tmp/vagrant/MySQL_setup"

   config.vm.provision :shell do |shell|
     shell.inline = "mkdir -p /etc/puppet/modules;
                     puppet module install puppetlabs/stdlib"
   end

   config.vm.provision "puppet" do |puppet|
     puppet.manifests_path = "manifests"
     puppet.manifest_file = "vagrant_manifest1.pp"
   end
  
   config.vm.provision :shell do |shell|
     shell.inline = "sudo cp -R /tmp/vagrant/redcap /var/www/html"
   end

   config.vm.provision "puppet" do |puppet|
     puppet.manifests_path = "manifests"
     puppet.manifest_file = "vagrant_manifest2.pp"
   end

   config.vm.network "forwarded_port", guest: 80, host: 1130

  # config.vm.box_check_update = false

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. 

 # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  
     # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

end
