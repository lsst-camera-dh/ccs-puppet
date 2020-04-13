class ccs_sysctl {

  $file = '99-lsst-daq-ccs.conf'

  file { "/etc/sysctl.d/${file}":
    source => "puppet:///modules/${title}/${file}",
    ensure => present,
    notify => Exec['sysctl'],
  }

  exec { 'sysctl':
    path => [ '/usr/sbin', '/usr/bin' ],
    command => "sysctl -p /etc/sysctl.d/${file}",
    refreshonly => true,
  }

}
