class ccs_software::jdk8 {

  $ccs_pkgarchive = lookup('ccs_pkgarchive', String)

  ## FIXME hiera
  $jdkrpm = 'jdk-8u251-linux-x64.rpm'
  ## The name of the package installed by the rpm.
  ## In older rpms, this had a version suffix, eg: jdk1.8.0_112
  $javaname = 'jdk1.8'
  ## The rpm installs to /usr/java/${javadir}
  ## The -amd64 suffix is a semi-recent addition, eg
  ## https://bugs.openjdk.java.net/browse/JDK-8202320
  ## The ever-changing world of java rpms:
  ## https://bugs.openjdk.java.net/browse/JDK-8202528
  ## TODO this seems like something we should derive.
  $javadir = 'jdk1.8.0_251-amd64'

  ## TODO https://forge.puppet.com/puppetlabs/java  ?

  $jdkfile = "/var/tmp/${jdkrpm}"

  archive { $jdkfile:
    ensure => present,
    source => "${ccs_pkgarchive}/${jdkrpm}",
  }

  ## TODO use a local yum repository?
  ##
  ## Note that (older) jdk8 rpms have the version in the name,
  ## eg "jdk1.8.0_112" rather than "jdk1.8", so that one can
  ## end up with multiple copies installed.
  ## https://bugs.openjdk.java.net/browse/JDK-8055864
  package { $javaname:
    ensure   => 'latest',
    provider => 'rpm',
    source   => $jdkfile,
  }


  ## TODO https://forge.puppet.com/puppet/alternatives  ?
  $cmds = ['java', 'javac', 'javaws', 'jar', 'jconsole', 'jstack']

  $cmds.each |$cmd| {
    $src = "/usr/bin/${cmd}"
    $dest = "/usr/java/${javadir}/bin/${cmd}"
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
