#
# == Class: bacula::console
#
# Setup Bacula console. Currently only install the package.
#
# == Parameters
#
# [*manage*]
#   Manage Bacula Console using Puppet. Valid values are true (default) and 
#   false.
# [*tls_enable*]
#   Enable TLS. Defaults to false.
# [*use_puppet_certs*]
#   Use puppet certs for TLS. Defaults to true.
# [*director_address_ipv4*]
#   IPv4 address of the Director to contact
# [*director_password*]
#   Director's console password
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class bacula::console
(
            $director_address_ipv4,
            $director_password,
    Boolean $manage = true,
    Boolean $tls_enable = false,
    Boolean $use_puppet_certs = true
)
{

if $manage {

    if ( $use_puppet_certs ) and ( $tls_enable ) {
        include ::bacula::puppetcerts
    }

    include ::bacula::common
    include ::bacula::console::install

    class { '::bacula::console::config':
        director_address_ipv4 => $director_address_ipv4,
        director_password     => $director_password,
        tls_enable            => $tls_enable,
    }
}
}
