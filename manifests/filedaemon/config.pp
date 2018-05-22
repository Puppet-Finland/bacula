#
# == Class: bacula::filedaemon::config
#
# Configure Bacula Filedaemon
#
class bacula::filedaemon::config
(
    Enum['present','absent']          $status,
    Boolean                           $is_director,
    Boolean                           $tls_enable,
    String                            $export_tag,
    String                            $pwd_for_director,
    String                            $pwd_for_monitor,
    String                            $bind_address,
    Array[String]                     $backup_files,
    Optional[Array[String]]           $exclude_files,
    Optional[Array[String]]           $schedules,
    Enum['All','AllButInformational'] $messages

) inherits bacula::params
{

    # If the filedaemon was not given a custom schedule, then use the default 
    # defined in the main Director configuration file. The $custom_schedules 
    # variable is used to avoid having to check for undef values in the ERB 
    # template loop.
    if $schedules {
        $schedule_name = "${::fqdn}-schedule"
    } else {
        $schedule_name = 'default-schedule'
    }

    File {
        ensure => $status,
        owner  => $::os::params::adminuser,
        mode   => '0640',
        notify  => Class['bacula::filedaemon::service'],
    }

    # Use a dynamic path separator to avoid *NIX-specifisms in bacula-fd.conf
    $sep = $::bacula::params::conf_path_sep

    file { 'bacula-bacula-fd.conf':
        name    => $::bacula::params::bacula_filedaemon_config,
        content => template('bacula/bacula-fd.conf.erb'),
        mode    => '0640',
        group   => $::os::params::admingroup,
        require => Class['bacula::filedaemon::install'],
    }

    $director_fragment_name = "/etc/bacula/bacula-dir.conf.d/${::fqdn}.conf"
    $director_fragment_content = template('bacula/bacula-dir.conf.d-fragment.erb')

    if $is_director {

        file { 'bacula-dir.conf.d-fragment-catalog':
            name    => '/etc/bacula/bacula-dir.conf.d/catalog.conf',
            content => template('bacula/bacula-dir-catalog.conf.erb'),
            group   => $::bacula::params::bacula_group,
            require => File['bacula-bacula-dir.conf.d'],
        }

        # Instantiate this resource directly if this is a Director node to
        # facilitate testing with Vagrant and "puppet apply".
        file { "bacula-dir.conf.d-fragment-${::fqdn}":
            name    => $director_fragment_name,
            content => $director_fragment_content,
            group   => $::bacula::params::bacula_group,
        }
    } else {
        # This is _not_ a Director node, so export a Director configuration 
        # fragment.
        @@file { "bacula-dir.conf.d-fragment-${::fqdn}":
            name    => $director_fragment_name,
            content => $director_fragment_content,
            group   => $::bacula::params::bacula_group,
            tag     => $export_tag,
            notify  => Class[$::bacula::director::service],
        }
    }
}
