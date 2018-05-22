#
# == Class: bacula::common::install
#
# Install common components for all bacula daemons
#
class bacula::common::install inherits bacula::params {

    if $::bacula::params::has_bacula_common_package {
        package { 'bacula-common':
            ensure => installed,
            name   => 'bacula-common',
        }
    }
}
