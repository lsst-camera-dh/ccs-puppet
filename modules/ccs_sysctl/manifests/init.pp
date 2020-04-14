class ccs_sysctl {

  $file = '99-lsst-daq-ccs.conf'

  file { "/etc/sysctl.d/${file}":
    ensure => present,
    source => "puppet:///modules/${title}/${file}",
    notify => Exec['sysctl'],
  }

  exec { 'sysctl':
    path        => [ '/usr/sbin', '/usr/bin' ],
    command     => "sysctl -p /etc/sysctl.d/${file}",
    refreshonly => true,
  }

}
