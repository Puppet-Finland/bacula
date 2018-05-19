#
# == Class: bacula::console::config
#
# Configure Bacula console
#
class bacula::console::config
(
    String  $director_hostname,
    String  $director_password,
    Boolean $tls_enable

) inherits bacula::params
{
    file { 'bacula-bconsole.conf':
        name    => '/etc/bacula/bconsole.conf',
        content => template('bacula/bconsole.conf.erb'),
        mode    => '0640',
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        require => Class['bacula::console::install'],
    }
}
