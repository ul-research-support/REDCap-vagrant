#Puppet Manifest for REDCap

#Updates each package to latest version as it's installed
exec { "apt-get update":
   command => "/usr/bin/apt-get update",
}

Exec["apt-get update"] -> Package <| |>

#Installs and runs apache2 web server
class apache2 {
   package { 'apache2':
      ensure  => present,
      require => Exec["apt-get update"],
   }

   service { 'apache2':
      ensure  => "running",
      require => Package["apache2"],
   }
}
class {'apache2':}

#Initial extraction of REDCap installation files
class extraction {
    #$redcap_version = inline_template("<%= `cd /var/www/html/redcap*; result=${PWD##*/}; echo $result | awk -F\"v\" '{ print $2 }'` %>")
    package { 'unzip':
       ensure => present,
       require => Package['apache2'],
    }
  exec { "extract":
     command => "unzip /vagrant/redcap*.zip -d /var/www/html",
     path => ["/usr/bin", "/bin"],
     require => Package['unzip'],
  }
  exec { "move":
     command => "cp -R /var/www/html/redcap7.0.15/redcap /var/www/html && rm -rf /var/www/html/redcap7.0.15",
     path => ["/usr/bin", "/bin"],
     require => Exec['redcap-version'],
  }
  exec { "redcap-version":
    command => "cd /var/www/html/redcap*; redcap_version=\${PWD##*/}; echo \$redcap_version | awk -F\"p\" '{ print $2 }'",
    path => ["/usr/bin", "/bin/cd"],
    require => Exec['extract'],
  }
}
class {'extraction':}

#Installs and runs MySQL, sets password, and moves SQL queries to VM
class mysql::server {
   package {'mysql-server':
       ensure => latest,
       require => Class['extraction'],
   }

   service {'mysql':
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
        require => Service['mysql'],
   }
   exec { "grant-${name}-db":
        unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
        command => "/usr/bin/mysql -uroot -hlocalhost -e \"GRANT ALL ON redcap.* TO ${user}@'localhost' IDENTIFIED BY '$password';\"",
        require => Service['mysql'],
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
UPDATE redcap_config SET value = '/var/www/html/redcap/hook_functions.php' WHERE field_name = 'hook_functions_file';
UPDATE redcap_config SET value = '7.0.15' WHERE field_name = 'redcap_version';
\"",
  require => Class['redcap_sql_setup'],
  subscribe => [Service['apache2'], Service['mysql']],
}

#Installs php5 scripting language and necessary extensions
class php {
   package {'php5':
      ensure => present,
   }
   package {'php5-mysql':
      ensure => present,
      require => Package['php5'],
   }
   # exec { 'repo_fix':
    #  command => "wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && rpm -Uvh epel-release-6*.rpm",
    #  path => ["/usr/bin", "/bin"],
    #  require => Package['php'],
    #  before => Package['php-mcrypt'],
    #}
   package {'php5-mcrypt':
      ensure => latest,
      require => Package['php5'],
      subscribe => Service['apache2'],
   }
   package {'php5-gd':
      ensure => latest,
      require => Package['php5'],
   }
   # package {'php5-dom':
   #    ensure => latest,
   #    require => Package['php5'],
   # }
   # package {'php5-xml':
   #    ensure => latest,
   #    require => Class['chown'],
   # }
   # package {'php5-mbstring':
   #    ensure => latest,
   #    require => Package['php5'],
   #}
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
    require => Package[php5],
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
    require => Package[php5],
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
    command => 'chown -R www:www/var/www/html/redcap/temp',
    path    => '/usr/local/bin/:/bin/',
    require => Class['credentials'],
  }

  exec {'chown_edocs':
    command => 'chown -R www:www /var/www/html/redcap/edocs',
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
    require => Class['chown'],
  }
}
class{'restart':}
