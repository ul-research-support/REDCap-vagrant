#Puppet Manifest for REDCap

#Updates each package to latest version as it's installed
exec { "apt-get update":
   command => "/usr/bin/apt-get update",
}

Exec["apt-get update"] -> Package <| |>

class apache {
  package {'apache2':
    ensure => latest,
  }

  service {'apache2':
    ensure => running
  }
}
class {'apache':}
#Installs and runs MySQL, sets password, and moves SQL queries to VM
class mysql::server {
   package {'mysql-server':
       ensure => latest,
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

# define mysqlsetup1 {
#    exec { "run_sql_setup1":
#       command => "/usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /var/www/html/redcap/redcap_v7.0.15/Resources/sql/install.sql",
#       path    => ["/usr/local/bin/:/var/www/html/redcap/redcap_v*/Resources/sql"],
#       require => Exec['flush'],
#    }
# }

# define mysqlsetup2 {
#    exec { "run_sql_setup2":
#       command => "/usr/bin/mysql -u redcap_user -predcapDBpassword redcap < /var/www/html/redcap/redcap_v7.0.15/Resources/sql/install_data.sql",
#       path    => ["/usr/local/bin/:/var/www/html/redcap/redcap_v*/Resources/sql"],
#       require => Exec['flush'],
#    }
# }

# class redcap_sql_setup {
#    mysqlsetup1 { "redcap":
#    }

#    mysqlsetup2 {"redcap":
#    }
# }
# class {'redcap_sql_setup':}


# exec { "update-redcap-db":
#   command => "/usr/bin/mysql -u redcap_user -predcapDBpassword redcap -e \"UPDATE redcap_config SET value = 'sha512' WHERE field_name = 'password_algo';
# UPDATE redcap_config SET value = '' WHERE field_name = 'redcap_csrf_token';
# UPDATE redcap_config SET value = '0' WHERE field_name = 'superusers_only_create_project';
# UPDATE redcap_config SET value = '1' WHERE field_name = 'superusers_only_move_to_prod';
# UPDATE redcap_config SET value = '1' WHERE field_name = 'auto_report_stats';
# UPDATE redcap_config SET value = '' WHERE field_name = 'bioportal_api_token';
# UPDATE redcap_config SET value = 'http://127.0.0.1:1130/redcap/' WHERE field_name = 'redcap_base_url';
# UPDATE redcap_config SET value = '1' WHERE field_name = 'enable_url_shortener';
# UPDATE redcap_config SET value = 'D/M/Y_12' WHERE field_name = 'default_datetime_format';
# UPDATE redcap_config SET value = ',' WHERE field_name = 'default_number_format_decimal';
# UPDATE redcap_config SET value = '.' WHERE field_name = 'default_number_format_thousands_sep';
# UPDATE redcap_config SET value = '/var/www/html/redcap/hook_functions.php' WHERE field_name = 'hook_functions_file';
# \"",
#   require => Class['redcap_sql_setup'],
#   subscribe => [Service['apache2'], Service['mysql']],
# }

#Installs php5 scripting language and necessary extensions
class php {
   package {'php5':
      ensure => present,
   }
   package {'php5-mysql':
      ensure => present,
      require => Package['php5'],
   }
   package {'php5-mcrypt':
      ensure => latest,
      require => Package['php5'],
      notify => Service['apache2'],
   }
   package {'php5-gd':
      ensure => latest,
      require => Package['php5'],
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
  exec { "sed -i 's/^;*[[:space:]]*$name[[:space:]]*=.*$/$name = $value/g' /etc/php5/apache2/php.ini":
    unless  => "grep -xqe '$name[[:space:]]*=[[:space:]]*$value' -- /etc/php.ini",
    path    => "/bin:/usr/bin",
    require => Package['php5'],
    notify  => Service['apache2'];
  }
}
set_php_var {
  "post_max_size":       value => '32M';
  "upload_max_filesize": value => '32M';
  "max_input_vars":      value => '20000';
}

define add_max_input_vars($value) {
  exec { "echo '$name = $value' >> /etc/php5/apache2/php.ini":
    path => "/bin:/usr/bin",
    require => Package['php5'],
    notify => Service['apache2'];
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
    require => Class['redcap::db'],
  }
  exec {'credential_setup2':
    command => 'echo "\$db = \'redcap\';" >>/var/www/html/redcap/database.php',
    path => ["/usr/bin", "/bin/"],
    require => Class['redcap::db'],
  }
  exec {'credential_setup3':
    command => 'echo "\$username = \'redcap_user\';" >>/var/www/html/redcap/database.php',
    path => ["/usr/bin", "/bin/"],
    require => Class['redcap::db'],
  }
  exec {'credential_setup4':
    command => 'echo "\$password = \'redcapDBpassword\';" >>/var/www/html/redcap/database.php',
    path => ["/usr/bin", "/bin/"],
    require => Class['redcap::db'],
  }
  exec {'credential_setup5':
    command => 'echo "\$salt = \'hard#hat\';" >>/var/www/html/redcap/database.php',
    path => ["/usr/bin", "/bin/"],
    require => Class['redcap::db'],
  }
}
class{'credentials':}
#These commands configure the REDCap server
class chown {
  exec {'chown_temp':
    command => 'chown -R www-data:www-data /var/www/html/redcap/temp',
    path    => '/usr/local/bin/:/bin/',
    require => Class['credentials'],
  }

  exec {'chown_edocs':
    command => 'chown -R www-data:www-data /var/www/html/redcap/edocs',
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
