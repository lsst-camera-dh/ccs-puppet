class profile::ccs::firewall {

  ensure_packages(['firewalld'])

  $ptitle = regsubst($title, '::', '/', 'G')

  if $facts['site'] == 'slac' {
    $file = 'trusted.xml'

    file { "/etc/firewalld/zones/${file}":
      ensure => file,
      source => "puppet:///modules/${ptitle}/${file}",
      notify => Service['firewalld'],
    }
  }


  service {'firewalld':
    ensure => 'stopped',
    enable => mask,
  }

}
