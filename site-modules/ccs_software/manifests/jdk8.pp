class ccs_software::jdk8 {

  $ccs_pkgarchive = lookup('ccs_pkgarchive', String)

  ## FIXME hiera
  $jdkrpm = 'jdk-8u251-linux-x64.rpm'
  ## The name of the package installed by the rpm.
  ## rpm -q -p $jdkrpm
  $javapkg = 'jdk1.8-1.8.0_251-fcs.x86_64'
  ## The rpm installs to /usr/java/jdk${javaver}
  ## Almost: rpm -qi -p ${jdkrpm} | awk '/^Version/ {print $3}'
  $javaver = '1.8.0_251-amd64'

  $jdkfile = "/var/tmp/${jdkrpm}"

  archive { $jdkfile:
    ensure => present,
    source => "${ccs_pkgarchive}/${jdkrpm}",
  }

  ## FIXME use a local yum repository.
  exec { 'Install jdk8':
    path      => ['/usr/bin'],
    unless    => "rpm -q --quiet ${javapkg}",
    ## Note that (some?) jdk8 rpms have the version in the name,
    ## eg "jdk1.8.0_112" rather than "jdk1.8", so that even with -U
    ## one ends up with multiple copies installed.
    ## https://bugs.openjdk.java.net/browse/JDK-8055864
    command   => "rpm -U ${jdkfile}",
    subscribe => Archive[$jdkfile],
  }


  ## TODO https://forge.puppet.com/puppet/alternatives  ?
  $cmds = ['java', 'javac', 'javaws', 'jar', 'jconsole', 'jstack']

  $cmds.each |$cmd| {
    $src = "/usr/bin/${cmd}"
    $dest = "/usr/java/jdk${javaver}/bin/${cmd}"
    exec {"java alternative for ${cmd}":
      path    => ['/usr/sbin', '/usr/bin'],
      ## The alternatives system seems to be flimsy.
      ## It can get into a confused state where you have to fix it
      ## with things like: rm /var/lib/alternatives/javaws
      command => @("CMD"/L),
        sh -c "test -e /etc/alternatives/${cmd} || \
        rm -f /var/lib/alternative/${cmd}; \
        update-alternatives --install ${src} ${cmd} ${dest} 1000 && \
        update-alternatives --set ${cmd} ${dest}"
        | CMD
      unless  => @("CMD"/L),
        sh -c "update-alternatives --display ${cmd} | \
        grep -q 'currently points to ${dest}'"
        | CMD
    }
  }


}
