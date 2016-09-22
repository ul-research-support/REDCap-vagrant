#Vagrant VM for REDCap

#### The Vagrantfile and Puppet manifests provided in this repository will allow you to create a virtual machine to run the REDCap database.

### Installation instructions:
To use this software you will need the latest version of [Vagrant] (https://www.vagrantup.com/downloads.html) and the 
latest version of [VirtualBox] (https://www.virtualbox.org/wiki/Downloads).

1. Download the REDCap-vagrant-master ZIP file from gituhub and extract it under a User on your computer

2. Open the "Vagrantfile" that came with the downloaded folder

3. Change the directory of "C:/Users/Chris/Desktop/redcap" located in the Vagrantfile to the directory of your REDCap folder

4. Change the beginning directory and version number of your REDcap folder in "**C:/Users/Chris/Desktop**/redcap/redcap_v**6.14.0**/Resources/sql"

5. Open your Command Prompt or Terminal, and change your directory to the project root (example: `cd Users/Chris/REDCap-vagrant-master`)

6. Type `vagrant up` and let it do it's magic

Vagrant will download the base box and run the Puppet provisioner to install Apache2, MySQL, PHP, necessary extensions, as well as set up the REDCap database users and tables.

At the end of the process, you should be able to navigate to http://127.0.0.1:1130/redcap/
