sudo apt-get update -y
sudo apt-get upgrade -y
sudo mkdir -p /etc/puppet/modules
sudo puppet module install puppetlabs/stdlib
sudo apt-get install apache2 -y
sudo apt-get install unzip -y
sudo unzip /vagrant/redcap-install/redcap*.zip -d /var/www/html
cd /var/www/html/redcap/redcap_v*; r_v=${PWD##*/}; redcap_version=$(echo $r_v | awk -F\"v\" '{ print $2 }')
echo $redcap_version > /vagrant/redcap-install/rv.txt
sudo puppet apply /vagrant/redcap-install/scripts/manifest.pp
redcap_version=$(cat /vagrant/rv.txt)
/usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /var/www/html/redcap/redcap_v${redcap_version}/Resources/sql/install.sql
/usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /var/www/html/redcap/redcap_v${redcap_version}/Resources/sql/install_data.sql
/usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /vagrant/redcap-install/scripts/redcap_extras.sql
rm -rf /vagrant/redcap-install/rv.txt