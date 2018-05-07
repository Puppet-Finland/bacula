#
# == Class: bacula::director
#
# Setup Bacula Director daemon.
#
# FIXME: for some reason granting privileges to the postgresql database tables 
# fails and has to be run manually. Tables are created without any issues. See 
# bacula::director::config::postgresql for details.
#
# == Parameters
#
# [*manage*]
#  Whether to manage Bacula Director with Puppet or not. Valid values are true
#  (default) and false.
# [*manage_db*]
#   Manage postgresql database. Valid values a true (default) and false. Set to 
#   no if you're using puppetlabs/postgresql or some other postgresql module.
# [*manage_packetfilter*]
#   Manage packet filtering rules. Valid values are true (default) and false.
# [*manage_monit*]
#   Manage monit rules. Valid values are true (default) and false.
# [*export_tag*]
#   Realize exported Bacula Director configuration fragments which have this 
#   tag. The value of this parameter must match what is configured for
#   ::bacula::filedaemon. This is useful during migrations and in cases where 
#   there are more than one Bacula Director running in the same network. 
#   Defaults to 'bacula-dir.conf.d-fragment' for compatibility with old module 
#   versions.
# [*console_host*]
#   Allow console connections from this IPv4 address. Defaults to 127.0.0.1
# [*bind_address*]
#   Bind to this IPv4 address. Defaults to 127.0.0.1.
# [*pwd_for_console*]
#   Password used for console connections to this director
# [*pwd_for_monitor*] 
#   Password used for monitoring connections to this director
# [*sd_host*]
#   IPv4 address of the Bacula storage daemon host. Defaults to 127.0.0.1.
# [*sd_password*]
#   Password used to connect to the storage daemon
# [*postgresql_auth_line*]
#   Authentication details for postgresql in pg_hba.conf format
# [*bacula_db_password*]
#   Password for the bacula database user
# [*tls_enable*]
#   Enable TLS. Valid values are true and false (default).
# [*use_puppet_certs*]
#   Use puppet certs for TLS. Valid values are true (default) and false.
# [*default_schedules*]
#   An array of "Run" lines to add to the default schedule used by Filedaemons.
#   Each Filedaemon can override this schedule with their own using the
#   schedules parameter. By default the following two Run lines are used:
#
#   'Level=Full sun at 05:00',
#   'Level=Incremental mon-sat at 05:00'
#
# [*file_retention*]
#   How long to keep File records in the catalog. This affects the Pool resource 
#   and overrides anything set in the client-specific configuration. Defaults to 
#   '60 days'.
# [*job_retention*]
#   The same as File retention but for Jobs. Defaults to '180 days'.
# [*volume_retention*]
#   How long to retain volumes. Defaults to '365 days'.
# [*max_volume_bytes*]
#   Maximum volume size in bytes. Defaults to '5G'.
# [*max_volumes*]
#   Maximum number of volumes. Defaults to 100.
# [*email*]
#   Email address where Bacula's internal notifications are sent. Defaults to 
#   global variable $::servermonitor.
# [*email_from*]
#   Sender email address. Defaults to "bacula@${::fqdn}". You may need to 
#   override this if your SMTP server rejects emails where From: address differs 
#   from the email account name; this is known to happen with Office 365 email 
#   servers.
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
class bacula::director
(
            $pwd_for_console,
            $pwd_for_monitor,
            $sd_password,
            $postgresql_auth_line,
            $bacula_db_password,
    Boolean $manage = true,
    Boolean $manage_db = true,
    Boolean $manage_packetfilter = true,
    Boolean $manage_monit = true,
    Boolean $use_puppet_certs = true,
    Boolean $tls_enable = false,
            $export_tag = 'bacula-dir.conf.d-fragment',
            $console_host = '127.0.0.1',
            $bind_address = '127.0.0.1',
            $sd_host = '127.0.0.1',
            $default_schedules = ['Level=Full sun at 05:00',
                                  'Level=Incremental mon-sat at 05:00'],
            $file_retention = '60 days',
            $job_retention = '180 days',
            $volume_retention = '365 days',
            $max_volume_bytes = '5G',
            $max_volumes = 100,
            $email_from = undef,
            $email = $::servermonitor,
            $monitor_email = $::servermonitor
)
{

if $manage {

    if ( $use_puppet_certs ) and ( $tls_enable ) {
        include ::bacula::puppetcerts
    }

    include ::bacula::common
    include ::bacula::director::install

    class { '::bacula::director::config':
        manage_db            => $manage_db,
        export_tag           => $export_tag,
        bind_address         => $bind_address,
        pwd_for_console      => $pwd_for_console,
        pwd_for_monitor      => $pwd_for_monitor,
        sd_host              => $sd_host,
        sd_password          => $sd_password,
        postgresql_auth_line => $postgresql_auth_line,
        bacula_db_password   => $bacula_db_password,
        tls_enable           => $tls_enable,
        default_schedules    => $default_schedules,
        email                => $email,
        email_from           => $email_from,
        file_retention       => $file_retention,
        job_retention        => $job_retention,
        volume_retention     => $volume_retention,
        max_volume_bytes     => $max_volume_bytes,
        max_volumes          => $max_volumes,
    }

    include ::bacula::director::service

    if $manage_monit {
        class { '::bacula::director::monit':
            monitor_email => $monitor_email,
        }
    }

    if $manage_packetfilter {
        class { '::bacula::director::packetfilter':
            console_host => $console_host,
        }
    }
}
}
