class ccs_firewall {

  ensure_packages(['firewalld'])


  if $facts['location'] == 'slac' {
    $file = 'trusted.xml'
  
    file { "/etc/firewalld/zones/${file}":
      ensure => file,
      source => "puppet:///modules/${title}/${file}",
      notify => Service['firewalld'],
    }
  }


  service {'firewalld':
    ensure => 'stopped',
    enable => mask,
  }

}
