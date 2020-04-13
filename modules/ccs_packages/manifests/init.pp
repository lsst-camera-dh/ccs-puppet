class ccs_packages ( Array[String] $packages ) {

  ensure_packages($packages)

  if $facts['role'] == 'desktop' {
    ensure_packages(['libreoffice-base'])
  }


  if $facts['location'] == 'slac' {
    ## Slow. Maybe better done separately?
    ## FIXME. Also don't want this on servers.
    ## Although people sometimes want to eg use vnc,
    ## so it does end up being needed on servers too.
    ## "Server with GUI" instead? Not much smaller.
    yum::group { 'GNOME Desktop':
      ensure  => present,
      timeout => 1800,
    }
  }


  ## EPEL
  ## FIXME graphical hosts only.
  if $facts['rpm_gdm'] == 'true' {
    ## This seems to be the smallest WM one can install.
    ensure_packages(['icewm','x2goclient','x2goserver','x2godesktopsharing'])
  }


  $pkgarchive = lookup('pkgarchive', String)

  if $facts['role'] == 'desktop' {
    ## FIXME use a local yum repository.
    exec { 'Install zoom':
      path => ['/usr/bin'],
      unless => 'rpm -q zoom',
      command => "sh -c \"rpm -U ${pkgarchive}/zoom*.rpm\"",
    }
  }


}
