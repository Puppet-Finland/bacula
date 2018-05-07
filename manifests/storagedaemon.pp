#
# == Class: bacula::storagedaemon
#
# Setup Bacula Storagedaemon.
#
# FIXME: add support for creating $backup_directory with correct permissions.
#
# == Parameters
#
# [*manage*]
#   Whether to manage Bacula Storagedaemon with Puppet or not. Valid values are 
#   true (default) and false.
# [*manage_packetfilter*]
#   Manage packet filtering rules. Valid values are true (default) and false.
# [*manage_monit*]
#   Manage monit rules. Valid values are true (default) and false.
# [*director_address_ipv4*]
#   IP-address for incoming Bacula Director packets.
# [*pwd_for_director*]
#   Password for the Director that contacts this filedaemon
# [*pwd_for_monitor*]
#   Password for the Monitor that contacts this filedaemon
# [*bind_address*]
#   Bind to this IPv4 address. Defaults to '127.0.0.1'. Set to '0.0.0.0' to 
#   listen on all interfaces..
# [*backup_directory*]
#   The directory where backups are stored. Defaults to '/var/backups/bacula'.
# [*tls_enable*]
#   Enable TLS. Valid values are true and false (default)
# [*use_puppet_certs*]
#   Use puppet certs for TLS. Valid values are true (default) and false.
# [*monitor_email*]
#   Email address where local service monitoring software sends it's reports to.
#   Defaults to global variable $::servermonitor.
# [*filedaemon_addresses_ipv4*]
#   An array of IPv4 address/networks from where to allow 
#   Filedaemon connections to the Storagedaemon
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
class bacula::storagedaemon
(
            $director_address_ipv4,
            $pwd_for_director,
            $pwd_for_monitor,
            $filedaemon_addresses_ipv4,
    Boolean $manage = true,
    Boolean $manage_packetfilter = true,
    Boolean $manage_monit = true,
            $bind_address = '127.0.0.1',
            $backup_directory = '/var/backups/bacula',
            $tls_enable = false,
            $use_puppet_certs = true,
            $monitor_email = $::servermonitor
)
{

if $manage {

    if ( $use_puppet_certs ) and ( $tls_enable ) {
        include ::bacula::puppetcerts
    }

    include ::bacula::common
    include ::bacula::storagedaemon::install

    class { '::bacula::storagedaemon::config':
        pwd_for_director => $pwd_for_director,
        pwd_for_monitor  => $pwd_for_monitor,
        bind_address     => $bind_address,
        backup_directory => $backup_directory,
        tls_enable       => $tls_enable,
    }

    include ::bacula::storagedaemon::service

    if $manage_packetfilter {
        class { '::bacula::storagedaemon::packetfilter':
            filedaemon_addresses_ipv4 => $filedaemon_addresses_ipv4,
            director_address_ipv4     => $director_address_ipv4,
        }
    }

    if $manage_monit {
        class { '::bacula::storagedaemon::monit':
            monitor_email => $monitor_email,
        }
    }
}
}
