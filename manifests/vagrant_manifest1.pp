#Puppet Manifest for Vagrant

#Updates each package to latest version as it's installed
exec { "apt-get update":
   command => "/usr/bin/apt-get update"
}

Exec["apt-get update"] -> Package <| |>

#Installs and runs Apache2 web server
class apache2 {
   package { "apache2":
      ensure  => present,
      require => Exec["apt-get update"],
   }

   service { "apache2":
      ensure  => "running",
      require => Package["apache2"],
   }
}
class {'apache2':}

#Installs and runs MySQL, sets password, and moves SQL queries to VM
class mysql::server {
   package {'mysql-server':
       ensure => latest,
   }

   service {'mysql':
       ensure  => running,
       require => Package['mysql-server'],
   }

   exec {'set_mysql_password':
       path    => ["/bin", "/usr/bin"],
       command => "mysqladmin -uroot password $mysql_password",
       require => Service['mysql'],
    }

   $mysql_password = "vagrant"
   
   exec {'move_MySQL_setup':
      command => 'cp -R /tmp/vagrant/MySQL_setup /var/www/html',
      path    => ['/usr/local/bin/:/bin/'],
      require => Package['apache2'],
   }
}
class {'mysql::server':}

#Creates a user in MySQL database that connects to the server
define mysqldb ( $user, $password ) {
   exec { "create-${name}-db":
        unless  => "/usr/bin/mysql -u${user} -p${password} ${name}",
        command => "/usr/bin/mysql -uroot -p$mysql_password -e \"CREATE SCHEMA ${name};\"",
        require => Service['mysql'],
   }
   exec { "grant-${name}-db":
        unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
        command => "/usr/bin/mysql -uroot -e \"GRANT ALL ON redcap.* TO ${user}@'%' IDENTIFIED BY '$password';\"",
        require => Service['mysql'],
   }
}

class redcap::db {
  mysqldb { "redcap":
     user     => "ID_user",
     password => "vagrant",
  }
}
class {'redcap::db':}

#Reloads privileges set in setup of new user
exec { "flush":
  command => "/usr/bin/mysql -uroot -e \"FLUSH PRIVILEGES;\"",
  require => Class['redcap::db'],
}

define mysqlsetup1 {
   exec { "run_sql_setup1":
      command => "/usr/bin/mysql -u ID_user -pvagrant redcap < /var/www/html/MySQL_setup/install.sql",
      path    => ["/usr/local/bin/:/var/www/html/MySQL_setup"],
      require => Class["redcap::db"],
   }
}

define mysqlsetup2 {
   exec { "run_sql_setup2":
      command => "/usr/bin/mysql -u ID_user -pvagrant redcap < /var/www/html/MySQL_setup/install_data.sql",
      path    => ["/usr/local/bin/:/var/www/html/MySQL_setup"],
      require => Class["redcap::db"],
   }
}

class redcap_sql_setup {
   mysqlsetup1 { "redcap":
   }
   
   mysqlsetup2 {"redcap":
   }
}
class {'redcap_sql_setup':}


exec { "update-redcap-db":
  command => "/usr/bin/mysql -u ID_user -pvagrant redcap -e \"UPDATE redcap_config SET value = 'sha512' WHERE field_name = 'password_algo';
UPDATE redcap_config SET value = '' WHERE field_name = 'redcap_csrf_token';
UPDATE redcap_config SET value = '0' WHERE field_name = 'superusers_only_create_project';
UPDATE redcap_config SET value = '1' WHERE field_name = 'superusers_only_move_to_prod';
UPDATE redcap_config SET value = '1' WHERE field_name = 'auto_report_stats';
UPDATE redcap_config SET value = '' WHERE field_name = 'bioportal_api_token';
UPDATE redcap_config SET value = 'http://127.0.0.1:1130/redcap/' WHERE field_name = 'redcap_base_url';
UPDATE redcap_config SET value = '1' WHERE field_name = 'enable_url_shortener';
UPDATE redcap_config SET value = 'D/M/Y_12' WHERE field_name = 'default_datetime_format';
UPDATE redcap_config SET value = ',' WHERE field_name = 'default_number_format_decimal';
UPDATE redcap_config SET value = '.' WHERE field_name = 'default_number_format_thousands_sep';
UPDATE redcap_config SET value = 'REDCap Administrator (123-456-7890)' WHERE field_name = 'homepage_contact';
UPDATE redcap_config SET value = 'email@yoursite.edu' WHERE field_name = 'homepage_contact_email';
UPDATE redcap_config SET value = 'REDCap Administrator (123-456-7890)' WHERE field_name = 'project_contact_name';
UPDATE redcap_config SET value = 'email@yoursite.edu' WHERE field_name = 'project_contact_email';
UPDATE redcap_config SET value = 'SoAndSo University' WHERE field_name = 'institution';
UPDATE redcap_config SET value = 'SoAndSo Institute for Clinical and Translational Research' WHERE field_name = 'site_org_type';
UPDATE redcap_config SET value = '/var/www/html/redcap/hook_functions.php' WHERE field_name = 'hook_functions_file';
UPDATE redcap_config SET value = '6.14.0' WHERE field_name = 'redcap_version';
\"",
  require => Class['redcap_sql_setup'],
}

#Installs php5 scripting language and necessary extensions
class php5 {
   package {'php5':
      ensure => latest,
   }

   package {'php5-mysqlnd':
      ensure => latest,
      require => Package['php5'],
   }

   package {'php5-mcrypt':
      ensure => latest,
      require => Package['php5'],
   }
   package {'php5-gd':
      ensure => latest,
      require => Package['php5'],
   }
   exec {'refresh_mcrypt':
      command => "php5enmod mcrypt",
      require => Package['php5-mcrypt'],
      path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin"],
      notify => Service['apache2'],
   }

   package {'php5-curl':
      ensure => latest,
      require => Package['php5'],
   }

   file {'/var/www/html/info.php':
      ensure => file,
      content => '<?php phpinfo(); ?>',
      require => Package['apache2'],
   }
}
class {'php5':}

#Sets different paramaters in php.ini file to certain values needed for REDCap integration
define set_php_var($value) {
  exec { "sed -i 's/^;*[[:space:]]*$name[[:space:]]*=.*$/$name = $value/g' /etc/php5/apache2/php.ini":
    unless  => "grep -xqe '$name[[:space:]]*=[[:space:]]*$value' -- /etc/php5/apache2/php.ini",
    path    => "/bin:/usr/bin",
    require => Package[php5],
    notify  => Service[apache2];
  }
}

set_php_var {
  "post_max_size":       value => '32M';
  "upload_max_filesize": value => '32M';
  "max_input_vars" :     value => '10000';
}
