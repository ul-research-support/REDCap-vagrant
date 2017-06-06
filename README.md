![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.803357.svg)

## Vagrant VM for REDCap

#### The Vagrantfile and Puppet manifests provided in this repository will allow you to create a virtual machine to run the REDCap database.

### Installation instructions:
To use this software you will need the latest version of [Vagrant](https://www.vagrantup.com/downloads.html) and the 
latest version of [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

1. Download the REDCap-vagrant-master ZIP file from gituhub and extract it under a User on your computer

2. Open the "Vagrantfile" that came with the downloaded folder

3. Place your redcap folder in the REDCap-vagrant-master folder and change the Vagrantfile to match your REDCap folder version

4. Open your Command Prompt or Terminal, and change your directory to the project root 

      Windows: `cd Users/(your name)/REDCap-vagrant-master`

      Mac OSX / Linux: `cd ~/REDCap-vagrant-master`

5. Type `vagrant up` and let it do it's magic

Vagrant will download the base box and run the Puppet provisioner to install Apache2, MySQL, PHP, necessary extensions, as well as set up the REDCap database users and tables.

At the end of the process, you should be able to navigate to http://127.0.0.1:1130/redcap/
