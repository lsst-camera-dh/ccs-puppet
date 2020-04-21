## @summary
##   Install newer java version for font rescaling on big display.
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent').
class profile::ccs::jdk11 ( String $ensure = 'nothing' ) {

  if $ensure =~ /(present|absent)/ {

    ensure_packages(['gzip', 'tar', 'unzip'])

    $pkgarchive = lookup('pkgarchive', String)

    $jvmdir = '/usr/lib/jvm'      # somewhere in /usr/local better?
    $jdkver = '11.0.2'
    $jdktar = "openjdk-${jdkver}_linux-x64_bin.tar.gz"
    ## TODO delete if ensure is absent.
    $jdkdest = "${jvmdir}/jdk-${jdkver}"

    archive { "/tmp/${jdktar}":
      ensure       => present,
      extract      => true,
      extract_path => $jvmdir,
      source       => "${pkgarchive}/${jdktar}",
      creates      => $jdkdest,
      cleanup      => true,
    }


    ## javafx is not included in this version.
    ## https://openjfx.io/openjfx-docs/#install-javafx
    $jfxver = $jdkver             # coincidence?
    $jfxzip = "openjfx-${jfxver}_linux-x64_bin-sdk.zip"
    ## TODO delete if install is false.
    $jfxdest = "${jvmdir}/javafx-sdk-${jfxver}"

    archive { "/tmp/${jfxzip}":
      ensure       => present,
      extract      => true,
      extract_path => $jvmdir,
      source       => "${pkgarchive}/${jfxzip}",
      creates      => $jfxdest,
      cleanup      => true,
    }


    $jdkcss = '/etc/ccs/jdk11'

    file { $jdkcss:
      ensure  => $ensure,
      content => epp("${title}/jdk11.epp", {'bindir' => "${jdkdest}/bin"}),
    }

    file { '/etc/ccs/ccs-console.app':
      ensure  => $ensure,
      content => epp(
        "${title}/ccs-console.epp",
        {'libdir' => "${jfxdest}/lib", 'jdkcss' => $jdkcss}
      ),
    }

  }

}
