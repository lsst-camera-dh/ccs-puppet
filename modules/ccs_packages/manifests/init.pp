class ccs_packages ( Array[String] $packages ) {

  ensure_packages($packages)


  ## Maybe this belongs in ccs_graphical.
  $pkgarchive = lookup('pkgarchive', String)

  if $facts['role'] == 'desktop' {
    ensure_packages(['libreoffice-base'])

    ## FIXME use a local yum repository.
    exec { 'Install zoom':
      path    => ['/usr/bin'],
      unless  => 'rpm -q zoom',
      command => "sh -c \"rpm -U ${pkgarchive}/zoom*.rpm\"",
    }
  }

}
