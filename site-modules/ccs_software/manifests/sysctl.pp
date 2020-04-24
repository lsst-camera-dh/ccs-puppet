class ccs_software::sysctl {

  $ptitle = regsubst($title, '::.*', '', 'G')

  $file = '99-lsst-ccs.conf'

  file { "/etc/sysctl.d/${file}":
    ensure => present,
    source => "puppet:///modules/${ptitle}/${file}",
    notify => Exec["sysctl ${file}"],
  }

  exec { "sysctl ${file}":
    path        => ['/usr/sbin', '/usr/bin'],
    command     => "sysctl -p /etc/sysctl.d/${file}",
    refreshonly => true,
  }

}
