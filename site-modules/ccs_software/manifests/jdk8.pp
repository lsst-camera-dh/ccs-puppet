class ccs_software::jdk8 {

  $ccs_pkgarchive = lookup('ccs_pkgarchive', String)

  ## TODO hiera
  $jdkrpm = 'jdk-8u112-linux-x64.rpm'
  ## FIXME: rpm -qi -p ${jdkrpm} | gawk '/^Version/ {print $3}'
  $javaver = '1.8.0_112'
  ## FIXME: rpm -q -p $jdkrpm
  $javapkg = 'jdk1.8.0_112-1.8.0_112-fcs.x86_64'

  $jdkfile = "/var/tmp/${jdkrpm}"

  archive { $jdkfile:
    ensure => present,
    source => "${ccs_pkgarchive}/${jdkrpm}",
  }

  ## FIXME use a local yum repository.
  exec { 'Install jdk8':
    path      => ['/usr/bin'],
    unless    => "rpm -q --quiet ${javapkg}",
    command   => "rpm -i ${jdkfile}",
    subscribe => Archive[$jdkfile],
  }


  $cmds = ['java', 'javac', 'javaws', 'jar', 'jconsole', 'jstack']

  $cmds.each |$cmd| {
    $src = "/usr/bin/${cmd}"
    $dest = "/usr/java/jdk${javaver}/bin/${cmd}"
    exec {"java alternative for ${cmd}":
      path    => ['/usr/sbin', '/usr/bin'],
      command => "sh -c \"update-alternatives --install ${src} ${cmd} ${dest} 1000 && update-alternatives --set ${cmd} ${dest}\"",
      unless  => "sh -c \"update-alternatives --display ${cmd} | grep -q 'currently points to '${dest}\""
    }
  }


}
