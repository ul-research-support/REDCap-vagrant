# vagrant
Installation instructions:
To use this software you will need the latest version of Vagrant software (located at https://www.vagrantup.com/downloads.html) and the 
latest version of VirtualBox (located at https://www.virtualbox.org/wiki/Downloads)

-Download the CTRSU/Vagrant ZIP file from github and extract it to a folder named "Vagrant" under a User on your computer

-Open the Vagrantfile that came with the downloaded folder

-Change the directory of "C:/Users/Chris/Desktop/redcap" located in the Vagrantfile to the directory of your redcap files

-Change the directory of "C:/Users/Chris/Vagrant/MySQL_setup" to "C:/(location of Vagrant folder on your computer)/Vagrant/MySQL_setup

-Open your Command Prompt or Terminal, change your directory to the directory of your Vagrantfile (example: "cd Users/Chris/Vagrant")

-Type "vagrant box add ubuntu/trusty64" and follow instructions

-Type "vagrant up" and let it do its magic

You should now be able to navigate to http://127.0.0.1:1130/redcap
