## @summary
##   Install Maven
##
## @param version
##   String giving version to install.
## @param dest
##   String giving directory to install to (parent must exist).

class ccs_software::maven (
  String $version = '3.6.3',
  String $dest = '/opt/maven',
) {

  $ccs_pkgarchive = lookup('ccs_pkgarchive', String)

  $tar = "apache-maven-${version}-bin.tar.gz"

  $dir = "${dest}/apache-maven-${version}"

  file { $dest:
    ensure => directory,
  }

  archive { "/var/tmp/${tar}":
    ensure       => present,
    extract      => true,
    extract_path => $dest,
    source       => "${ccs_pkgarchive}/${tar}",
    creates      => $dir,
    cleanup      => true,
  }


  file { '/etc/profile.d/ccs-maven.sh':
    ensure  => present,
    content => "PATH=${dir}/bin:\$PATH\n",
  }

}
