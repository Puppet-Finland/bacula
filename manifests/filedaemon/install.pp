#
# == Class: bacula::filedaemon::install
#
# Install Bacula Filedaemon
#
class bacula::filedaemon::install
(
    Enum['present','absent'] $status,
    String                   $package_name,
    Optional[String]         $package_version,

) inherits bacula::params
{

    if $::bacula::params::bacula_filedaemon_installable {

        if ($status == 'present') and ($package_version) {
            $package_ensure = $package_version
        } else {
            $package_ensure = $status
        }

        package { 'bacula-filedaemon':
            ensure  => $package_ensure,
            name    => $package_name,
            require => Class['::bacula::common'],
        }
    }
}
