#
# == Class: bacula::filedaemon::packetfilter
#
# Configure packet filtering rules for Bacula Filedaemon
# 
class bacula::filedaemon::packetfilter
(
    Enum['present','absent'] $status,
    String                   $director_address_ipv4
)
{
    if $::kernel == 'windows' {
        ::windows_firewall::exception { 'bacula-director':
            ensure       => $status,
            direction    => 'in',
            action       => 'allow',
            enabled      => true,
            protocol     => 'TCP',
            local_port   => 9102,
            remote_ip    => $director_address_ipv4,
            display_name => 'Bacula Director-in',
            description  => 'Allow Bacula Director connections to tcp port 9102',
        }
    } else {
        @firewall { "012 ipv4 accept bacula filedaemon port from ${director_address_ipv4}":
            ensure   => $status,
            provider => 'iptables',
            chain    => 'INPUT',
            proto    => 'tcp',
            dport    => 9102,
            source   => $director_address_ipv4,
            action   => 'accept',
            tag      => 'default',
        }
    }
}
