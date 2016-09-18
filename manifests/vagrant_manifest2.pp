#Second Puppet Manifest for Vagrant

#These credential setups automate the connection to the database server without asking for login information
file_line {'database_credential_setup1':
   path => '/var/www/html/redcap/database.php',
   line => "\$hostname = 'localhost';",
}

file_line {'database_credential_setup2':
   path => '/var/www/html/redcap/database.php',
   line => "\$db = 'redcap';",
}

file_line {'database_credential_setup3':
   path => '/var/www/html/redcap/database.php',
   line => "\$username = 'ID_user';",
}

file_line {'database_credential_setup4':
   path => '/var/www/html/redcap/database.php',
   line => "\$password = 'vagrant';",
}

file_line {'database_credential_setup5':
   path => '/var/www/html/redcap/database.php',
   line => "\$salt = 'q79ncml1006';",
}

#These commands configure the REDCap server
exec {'chown_temp':
  command => 'chown -R www-data:www-data /var/www/html/redcap/temp',
  path    => '/usr/local/bin/:/bin/',
}

exec {'chown_edocs':
  command => 'chown -R www-data:www-data /var/www/html/redcap/edocs',
  path    => '/usr/local/bin/:/bin/',
}

exec {'crontab_setup':
   command => 'crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/html/redcap/cron.php" | crontab -',
   path    => ["/usr/bin","/bin", "/usr/sbin", "/sbin"],
}