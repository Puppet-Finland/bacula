#
# == Class: bacula::common
#
# Setup common components for all bacula daemons
#
class bacula::common inherits bacula::params {

    $bacula_group = $::bacula::params::bacula_group

    # We need to create the bacula group _before_ installing Bacula, or the 
    # ::bacula::puppetcerts class will fail on first Puppet run. On Windows
    # Bacula group management is not needed or wanted.
    if $bacula_group {
        group { $bacula_group:
            ensure => present,
            gid    => $::bacula::params::bacula_gid
        }
    }

    class { '::bacula::common::install': }
}

