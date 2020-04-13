class ccs_fail2ban {

  ensure_packages(['fail2ban'])


  if $facts['location'] == 'slac' {
    $files = ['jail.d/10-lsst-ccs.conf', 'paths-overrides.local']

    $files.each |$file| {
      $src = basename($file)
      file { "/etc/fail2ban/${file}":
        ensure => file,
        source => "puppet:///modules/${title}/${src}",
        notify => Service['fail2ban'],
      }
    }
  }


  service {'fail2ban':
    ensure => 'stopped',
    enable => mask,
  }

}
