## Vagrant VM for REDCap
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.814023.svg)](http://dx.doi.org/10.5281/zenodo.814023)

#### The Vagrantfile and Puppet manifests provided in this repository will allow you to create a virtual machine to run a HIPAA-compliant fully-functional encrypted REDCap instance.

### Installation instructions:
To use this software you will need the latest version of [Vagrant](https://www.vagrantup.com/downloads.html) and the 
latest version of [VirtualBox](https://www.virtualbox.org/wiki/Downloads). You will also need the VirtualBox Extension Pack corresponding to your VirtualBox version.

1. Download the REDCap-vagrant-master ZIP file from GitHub and extract it on your computer

2. Place your REDCap installation folder in your newly-downloaded REDCap-vagrant-master folder

3. Open your Terminal or Command Prompt, and change your directory to the project root 

4. Run either the startup.sh script or the startup.bat script with `sudo ./startup.sh`, or `startup.bat` respectively.

#### Special note for Windows users: You will need to enter in your Windows username when prompted as well as the Hard Disk UUID of the virtual machine when prompted. The UUID will be shown to you, but you must make sure to enter in the Hard Disk or Image UUID and not the Machine UUID. If you are stuck, enter in the Image UUID located directly above the prompt.

Vagrant will download the base box and prompt you for a password to encrypt the hard drive. The default username is `redcap_user`. Vagrant will run the Puppet provisioner to install Apache2, MySQL, PHP, necessary extensions, as well as set up the REDCap database users and tables.

At the end of the process, you should be able to navigate to http://127.0.0.1:1130/redcap/
