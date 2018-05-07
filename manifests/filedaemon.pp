#
# == Class: bacula::filedaemon
#
# Setup Bacula Director daemon. The list of backed up machines is generated 
# dynamically from configuration file fragments exported by nodes that include 
# the bacula::filedaemon class. In other words, the filedaemon nodes add 
# themselves to the backup cycle.
#
# == Parameters
#
# [*manage*]
#   Manage Bacula Filedaemon using Puppet. Valid values are true (default) and 
#   false.
# [*manage_packetfilter*]
#   Manage packet filtering rules. Valid values are true (default) and false.
# [*manage_monit*]
#   Manage monit rules. Valid values are true (default) and false.
# [*export_tag*]
#  Export Bacula Director configuration fragments with this tag. This must match 
#  what is configured for ::bacula::director. Defaults to 
#  'bacula-dir.conf.d-fragment' for compatibility with old module versions.
# [*status*]
#   Status of the Bacula Filedaemon. Valid values are 'present' and 'absent'. 
#   Default value is 'present'. This is primary useful when decommissioning 
#   nodes to ensure that exported resources are cleaned up properly.
# [*is_director*]
#   Determines if this node is a Director also. Used to add catalog backup job 
#   and to instantiate the filedaemon's main backup job without exporting it 
#   first. Valid values are true and false (default).
# [*package_name*]
#   Override the default package name obtained from params.pp. This is useful
#   if your operating system provides two different bacula-fd/bacula-client 
#   versions under different names, e.g. for compatibility reasons. For example 
#   on FreeBSD 10 you need to set this parameter to 'bacula5-client' to be able 
#   to connect to 5.2.x-based Directors and StorageDaemons.
# [*director_address_ipv4*]
#   IP-address for incoming Bacula Director packets.
# [*pwd_for_director*]
#   Password for the Director that contacts this filedaemon
# [*pwd_for_monitor*]
#   Password for the Monitor that contacts this filedaemon
# [*bind_address*]
#   Bind to this IPv4 address. Defaults to '127.0.0.1'. Use '0.0.0.0' to bind to 
#   all interfaces.
# [*tls_enable*]
#   Enable TLS. Valid values are true and false (default).
# [*use_puppet_certs*]
#   Use puppet certs for TLS. Valid values are true (default) and false.
# [*backup_files*]
#   An array containing the list of directories/files to backup
# [*exclude_files*]
#   An array containing a list of directories/files/wildcards to exclude from 
#   backups. Defaults to undef.
# [*schedules*]
#   An array containing "Run" lines for a Filedaemon-specific schedule.
#   Defaults to undef which means that the default Schedule called
#   "default-schedule" defined in the bacula::director class is used.
# [*messages*]
#   Which messages should be sent via email. Use "All" for (almost) all
#   messages and "AllButInformational" for everything except "Backup OK of
#   <node>..." messages and like. Defaults to "All".
# [*monitor_email*]
#   Email address where local service monitoring software sends it's reports to.
#   Defaults to global variable $::servermonitor.
#
# == Authors
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# Samuli Seppänen <samuli@openvpn.net>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class bacula::filedaemon
(
            $director_address_ipv4,
            $pwd_for_director,
            $pwd_for_monitor,
            $backup_files,
    Enum['present','absent'] $status = 'present',
    Boolean $manage = true,
    Boolean $manage_packetfilter = true,
    Boolean $manage_monit = true,
    Boolean $use_puppet_certs = true,
    Boolean $tls_enable = false,
            $export_tag = 'bacula-dir.conf.d-fragment',
            $package_name = $::bacula::params::bacula_filedaemon_package,
            $is_director = false,
            $bind_address = '127.0.0.1',
            $exclude_files = undef,
            $schedules = undef,
            $messages = 'All',
            $monitor_email = $::servermonitor

) inherits bacula::params
{

if $manage {

    # Remove obsolete configurations
    include ::bacula::filedaemon::absent

    if ( $use_puppet_certs ) and ( $tls_enable ) {
        include ::bacula::puppetcerts
    }

    include ::bacula::common

    class { '::bacula::filedaemon::install':
        status       => $status,
        package_name => $package_name,
    }

    class { '::bacula::filedaemon::config':
        status           => $status,
        is_director      => $is_director,
        export_tag       => $export_tag,
        pwd_for_director => $pwd_for_director,
        pwd_for_monitor  => $pwd_for_monitor,
        bind_address     => $bind_address,
        tls_enable       => $tls_enable,
        backup_files     => $backup_files,
        exclude_files    => $exclude_files,
        schedules        => $schedules,
        messages         => $messages,
    }

    class { '::bacula::filedaemon::service':
        ensure => $status,
    }

    if $manage_packetfilter {
        class { '::bacula::filedaemon::packetfilter':
            status                => $status,
            director_address_ipv4 => $director_address_ipv4,
        }
    }

    if $manage_monit {
        class { '::bacula::filedaemon::monit':
            status        => $status,
            monitor_email => $monitor_email,
        }
    }
}
}
