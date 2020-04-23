class profile::slac::fail2ban {

  ensure_packages(['fail2ban'])

  $ptitle = regsubst($title, '::', '/', 'G')

  if $facts['site'] == 'slac' {
    $files = ['jail.d/10-lsst-ccs.conf', 'paths-overrides.local']

    $files.each |$file| {
      $src = basename($file)
      file { "/etc/fail2ban/${file}":
        ensure => file,
        source => "puppet:///modules/${ptitle}/${src}",
        notify => Service['fail2ban'],
      }
    }
  }


  service {'fail2ban':
    ensure => 'stopped',
    enable => mask,
  }

}
