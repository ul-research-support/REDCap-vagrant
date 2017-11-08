#Puppet Manifest for REDCap

#Updates each package to latest version as it's installed
exec { "yum update":
   command => "/usr/bin/yum update",
}

Exec["yum update"] -> Package <| |>

#Installs and runs apache2 web server
class apache2 {
   package { 'apache2':
      ensure  => present,
      require => Exec["yum update"],
   }

   service { 'apache2':
      ensure  => "running",
      require => Package["apache2"],
   }
}
class {'apache2':}

#Initial extraction of REDCap installation files
class extraction {
    package { 'unzip':
       ensure => present,
       require => Package['apache2'],
    }
	exec { "extract":
	   command => "unzip redcap*.zip -d /var/www/html",
	   path => ["/usr/bin", "/bin"],
	   require => Package['unzip'],
	}
}
class {'extraction':}

#Installs and runs MySQL, sets password, and moves SQL queries to VM
class mysql::server {
   package {'mysql-server':
       ensure => latest,
       require => Class['extraction'],
   }

   service {'mysqld':
       ensure  => running,
       require => Package['mysql-server'],
   }


   $mysql_password = 'redcapDBpassword'
}
class {'mysql::server':}

#Creates a user in MySQL database that connects to the server
define mysqldb ( $user, $password ) {
   exec { "create-${name}-db":
        unless  => "/usr/bin/mysql -u${user} -p${password} ${name}",
        command => "/usr/bin/mysql -uroot -hlocalhost -e \"CREATE SCHEMA ${name};\"",
        require => Service['mysqld'],
   }
   exec { "grant-${name}-db":
        unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
        command => "/usr/bin/mysql -uroot -hlocalhost -e \"GRANT ALL ON redcap.* TO ${user}@'localhost' IDENTIFIED BY '$password';\"",
        require => Service['mysqld'],
   }
}

class redcap::db {
  mysqldb { "redcap":
     user     => "redcap_user",
     password => "redcapDBpassword",
  }
}
class {'redcap::db':}

#Reloads privileges set in setup of new user
exec { "flush":
  command => "/usr/bin/mysql -uroot -hlocalhost -e \"FLUSH PRIVILEGES;\"",
  require => Class['redcap::db'],
}

define mysqlsetup1 {
   exec { "run_sql_setup1":
      command => "/usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /var/www/html/redcap/redcap_v7.0.15/Resources/sql/install.sql",
      path    => ["/usr/local/bin/:/var/www/html/redcap/redcap_v*/Resources/sql"],
      require => Exec['flush'],
   }
}

define mysqlsetup2 {
   exec { "run_sql_setup2":
      command => "/usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /var/www/html/redcap/redcap_v7.0.15/Resources/sql/install_data.sql",
      path    => ["/usr/local/bin/:/var/www/html/redcap/redcap_v*/Resources/sql"],
      require => Exec['flush'],
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
  command => "/usr/bin/mysql -u redcap_user -predcapDBpassword redcap -e \"UPDATE redcap_config SET value = 'sha512' WHERE field_name = 'password_algo';
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
UPDATE redcap_config SET value = '7.0.15' WHERE field_name = 'redcap_version';
\"",
  require => Class['redcap_sql_setup'],
  subscribe => [Service['apache2'], Service['mysqld']],
}

#Installs php5 scripting language and necessary extensions
class php {
   package {'php':
      ensure => present,
   }
   package {'php-mysql':
      ensure => present,
      require => Package['php'],
   }
   exec { 'repo_fix':
	   command => "wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && rpm -Uvh epel-release-6*.rpm",
	   path => ["/usr/bin", "/bin"],
	   require => Package['php'],
	   before => Package['php-mcrypt'],
    }
   package {'php-mcrypt':
      ensure => latest,
      require => Package['php'],
      subscribe => Service['apache2'],
   }
   package {'php-gd':
      ensure => latest,
      require => Package['php'],
   }
   package {'php-dom':
      ensure => latest,
      require => Package['php'],
   }
   package {'php-xml':
      ensure => latest,
      require => Class['chown'],
   }
   package {'php-mbstring':
      ensure => latest,
      require => Package['php'],
   }
   file {'/var/www/html/info.php':
      ensure => file,
      content => '<?php phpinfo(); ?>',
      require => Package['apache2'],
   }
}
class {'php':}

#Sets different paramaters in php.ini file to certain values needed for REDCap integration
define set_php_var($value) {
  exec { "sed -i 's/^;*[[:space:]]*$name[[:space:]]*=.*$/$name = $value/g' /etc/php.ini":
    unless  => "grep -xqe '$name[[:space:]]*=[[:space:]]*$value' -- /etc/php.ini",
    path    => "/bin:/usr/bin",
    require => Package[php],
    notify  => Service[apache2];
  }
}
set_php_var {
  "post_max_size":       value => '32M';
  "upload_max_filesize": value => '32M';
  "max_input_vars":      value => '20000';
}

define add_max_input_vars($value) {
  exec { "echo '$name = $value' >> /etc/php.ini":
    path => "/bin:/usr/bin",
    require => Package[php],
    notify => Service[apache2];
    }
}
add_max_input_vars {
  "max_input_vars": value => '20000';
}

#These credential setups automate the connection to the database server without asking for login information
class credentials {
	exec {'credential_setup1':
	  command => 'echo "\$hostname = \'localhost\';" >>/var/www/html/redcap/database.php',
	  path => ["/usr/bin", "/bin/"],
	  require => Class['redcap_sql_setup'],
	}
	exec {'credential_setup2':
	  command => 'echo "\$db = \'redcap\';" >>/var/www/html/redcap/database.php',
	  path => ["/usr/bin", "/bin/"],
	  require => Class['redcap_sql_setup'],
	}
	exec {'credential_setup3':
	  command => 'echo "\$username = \'redcap_user\';" >>/var/www/html/redcap/database.php',
	  path => ["/usr/bin", "/bin/"],
	  require => Class['redcap_sql_setup'],
	}
	exec {'credential_setup4':
	  command => 'echo "\$password = \'Medcenter140b\';" >>/var/www/html/redcap/database.php',
	  path => ["/usr/bin", "/bin/"],
	  require => Class['redcap_sql_setup'],
	}
	exec {'credential_setup5':
	  command => 'echo "\$salt = \'hard#hat\';" >>/var/www/html/redcap/database.php',
	  path => ["/usr/bin", "/bin/"],
	  require => Class['redcap_sql_setup'],
	}
}
class{'credentials':}
#These commands configure the REDCap server
class chown {
	exec {'chown_temp':
	  command => 'chown -R apache:apache /var/www/html/redcap/temp',
	  path    => '/usr/local/bin/:/bin/',
	  require => Class['credentials'],
	}

	exec {'chown_edocs':
	  command => 'chown -R apache:apache /var/www/html/redcap/edocs',
	  path    => '/usr/local/bin/:/bin/',
	  require => Class['credentials'],
	}

	exec {'crontab_setup':
	   command => 'crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/html/redcap/cron.php" | crontab -',
	   path    => ["/usr/bin","/bin", "/usr/sbin", "/sbin"],
	   require => Class['credentials'],
	}
}
class{'chown':}

class restart {
  exec {'apache2_restart':
    command => '/etc/init.d/apache2 restart && mkdir /var/www/foo',
    require => Package['php-xml'],
  }
}
class{'restart':}
