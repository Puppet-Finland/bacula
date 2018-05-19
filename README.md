# Bacula

A puppet module to manage Bacula Directors, Storagedaemons and Filedaemons.
Puppet certificates are used for TLS. Optional firewall and monit support
is included.

# Module usage

The Puppet manifests written for Vagrant show how to use the module:

* [All daemons+console](vagrant/all.pp)
* [Filedaemon only](vagrant/fd.pp)

For those viewing this README through Puppet Forge here is the first one in
full:

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
        tls_enable            => false,
        use_puppet_certs      => false,
        director_hostname     => 'bacula.example.org',
        director_password     => 'console',
    }

For further details refer to module entrypoints:

* [Class: bacula::director](manifests/director.pp)
* [Class: bacula::storagedaemon](manifests/storagedaemon.pp)
* [Class: bacula::filedaemon](manifests/filedaemon.pp)
* [Class: bacula::console](manifests/console.pp)
