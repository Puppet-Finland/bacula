#
# == Class: bacula::common::install
#
# Install common components for all bacula daemons
#
class bacula::common::install
(
    Optional[String] $package_version = undef

) inherits bacula::params {

    if $::bacula::params::has_bacula_common_package {
        if $package_version {
            $package_ensure = $package_version
        } else {
            $package_ensure = 'present'
        }

        package { 'bacula-common':
            ensure => $package_ensure,
            name   => 'bacula-common',
        }
    }
}
