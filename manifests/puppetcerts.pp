#
# == Class: bacula::puppetcerts
#
# Copy puppet certificates to a place where Bacula daemons can find them. Note 
# that this class depends on puppetagent::params class for locating Puppet's 
# SSL certificates.
#
class bacula::puppetcerts {

    include ::bacula::params
    include ::puppetagent::params

    file { 'bacula-conf-dir':
        ensure  => directory,
        name    => $::bacula::params::conf_dir,
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0755',
        require => Class['bacula::common'],
    }

    file { 'bacula-ssl-dir':
        ensure  => directory,
        name    => $::bacula::params::ssl_dir,
        mode    => '0750',
        owner   => $::os::params::adminuser,
        group   => $::bacula::params::bacula_group,
        require => File['bacula-conf-dir'],
    }

    $keys = {   "${::puppetagent::params::ssldir}/certs/${::fqdn}.pem"        => "${::bacula::params::ssl_dir}/bacula.crt",
                "${::puppetagent::params::ssldir}/private_keys/${::fqdn}.pem" => "${::bacula::params::ssl_dir}/bacula.key",
                "${::puppetagent::params::ssldir}/certs/ca.pem"               => "${::bacula::params::ssl_dir}/bacula-ca.crt", }

    $keys.each |$key| {
        file { $key[1]:
            name   => $key[1],
            source => $key[0],
            mode   => '0640',
            owner  => $::os::params::adminuser,
            group  => $::bacula::params::bacula_group,
        }
    }
}
