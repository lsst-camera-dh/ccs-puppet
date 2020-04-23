## @summary
##   Settings for hosts that should run in graphical mode.
##
## @param install
##   Boolean, false means do nothing.

class profile::ccs::graphical (Boolean $install = false) {

  if $install {

    ensure_packages(['gdm'])

    service { 'gdm':
      enable => true,
    }

    exec { 'Set graphical target':
      path    => ['/usr/sbin', '/usr/bin'],
      command => 'systemctl set-default graphical.target',
      unless  => 'sh -c "systemctl get-default | grep -qF graphical.target"',
    }

    ## Slow. Maybe better done separately?
    ## Don't want this on servers.
    ## Although people sometimes want to eg use vnc,
    ## so it does end up being needed on servers too.
    ## "Server with GUI" instead? Not much smaller.
    yum::group { 'GNOME Desktop':
      ensure  => present,
      timeout => 1800,
    }

    package { 'gnome-initial-setup':
      ensure => purged,
    }

    ensure_packages(['x2goclient', 'x2goserver', 'x2godesktopsharing'])

    ensure_packages(['icewm'])

    yum::group { 'MATE Desktop':
      ensure  => present,
      timeout => 900,
    }

  }


  if $facts['role'] =~ /(desktop|viswork)/ {

    ensure_packages(['libreoffice-base'])

    $pkgarchive = lookup('pkgarchive', String)

    ## FIXME use a local yum repository.
    exec { 'Install zoom':
      path    => ['/usr/bin'],
      unless  => 'rpm -q zoom',
      command => "sh -c \"rpm -U ${pkgarchive}/zoom*.rpm\"",
    }
  }


}
