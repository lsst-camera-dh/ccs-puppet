## @summary
##   Add (or remove) the lion canbus module.
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent') module.
class ccs_hcu::canbus (String $ensure = 'nothing') {

  $ptitle = regsubst($title, '::.*', '', 'G')

  if $ensure =~ /(present|absent)/ {

    ensure_packages(['xz', 'tar'])

    $module = lookup('ccs_hcu::canbus::module')
    $version = lookup('ccs_hcu::canbus::version')
    $ccs_pkgarchive = lookup('ccs_pkgarchive', String)
    ## Patched version with dkms.conf and fixed driver/Makefile.
    $src = "${module}_V${version}_dkms.tar.xz"
    $lmodule = "${downcase($module)}"
    $dest = "${lmodule}-${version}"

    ## Ensure => absent does not delete the extracted file.
    archive { '/var/tmp/canbus.tar.xz':
      ensure       => $ensure,
      extract      => true,
      extract_path => '/usr/src',
      source       => "${ccs_pkgarchive}/${src}",
      creates      => "/usr/src/${dest}",
      cleanup      => true,
    }


    ccs_hcu::dkms { 'canbus':
      ensure  => $ensure,
      module  => $lmodule,
      version => $version,
      archive => '/var/tmp/canbus.tar.xz',
    }


    $conf = 'canbus.conf'

    file { "/etc/modules-load.d/${conf}":
      ensure => $ensure,
      source => "puppet:///modules/${ptitle}/${conf}",
    }


    $exec = '/usr/local/libexec/canbus-init'

    file { $exec:
      ensure => $ensure,
      source => "puppet:///modules/${ptitle}/${basename($exec)}",
      mode   => '0755',
    }


    if $ensure == absent {
      service { 'canbus':
        ensure => stopped,
        enable => false,
      }
    }


    $service = 'canbus.service'

    file { "/etc/systemd/system/${service}":
      ensure  => $ensure,
      content => epp("${ptitle}/${service}.epp", {'exec' => $exec}),
    }


    if $ensure == present {
      ## $exec fails if there is no canbus interface.
      service { 'canbus':
        ensure => running,
        enable => true,
      }
    }

  }

}
