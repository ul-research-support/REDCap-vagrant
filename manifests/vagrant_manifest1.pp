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


define mysqlsetup {
   exec { "run_sql_setup":
      command => "/usr/bin/mysql -u ID_user -pvagrant redcap < /var/www/html/MySQL_setup/sql_setup.sql",
      path    => ["/usr/local/bin/:/var/www/html/MySQL_setup"],
      require => Class["redcap::db"],
   }
}

class redcap_sql_setup {
   mysqlsetup { "redcap":
   }
}
class {'redcap_sql_setup':}

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
