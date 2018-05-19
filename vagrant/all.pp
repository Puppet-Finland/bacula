# This manifest is only used by Vagrant

$email = 'root@localhost'

class { '::monit':
    email => $email,
}

class { '::bacula::director':
    manage_db            => true,
    manage_packetfilter  => true,
    manage_monit         => true,
    tls_enable           => false,
    use_puppet_certs     => false,
    console_host         => 'localhost',
    pwd_for_console      => 'console',
    pwd_for_monitor      => 'monitor',
    sd_host              => '127.0.0.1',
    sd_password          => 'director',
    postgresql_auth_line => 'local bacula baculauser  password',
    bacula_db_password   => 'db',
    bind_address         => '0.0.0.0',
    file_retention       => '30 days',
    job_retention        => '90 days',
    volume_retention     => '180 days',
    max_volume_bytes     => '100M',
    max_volumes          => '5',
    email                => $email,
    monitor_email        => $email,
}

class { '::bacula::storagedaemon':
    manage_packetfilter       => true,
    manage_monit              => true,
    director_address_ipv4     => '127.0.0.1',
    pwd_for_director          => 'director',
    pwd_for_monitor           => 'monitor',
    backup_directory          => '/var/backups/bacula',
    monitor_email             => $email,
    filedaemon_addresses_ipv4 => ['192.168.138.0/24'],
}

class { '::bacula::filedaemon':
    is_director           => true,
    status                => 'present',
    manage_packetfilter   => true,
    manage_monit          => true,
    use_puppet_certs      => false,
    tls_enable            => false,
    director_address_ipv4 => '192.168.138.200',
    pwd_for_director      => 'director',
    pwd_for_monitor       => 'monitor',
    backup_files          => [ '/tmp/modules' ],
    messages              => 'AllButInformational',
    monitor_email         => $email,
}

class { '::bacula::console':
    tls_enable        => false,
    use_puppet_certs  => false,
    director_hostname => '127.0.0.1',
    director_password => 'console',

}
