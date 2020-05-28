## @summary
##   Add (or remove) the iManager module.
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent') module.
class ccs_hcu::imanager (String $ensure = 'nothing') {

  if $ensure =~ /(present|absent)/ {

    ensure_packages(['xz', 'tar'])

    $module = lookup('ccs_hcu::imanager::module')
    $version = lookup('ccs_hcu::imanager::version')
    $ccs_pkgarchive = lookup('ccs_pkgarchive', String)
    ## Patched version with dkms.conf and fixed Makefile.
    $src = "${module}-${version}_dkms.tar.xz"
    $dest = "${module}-${version}"

    ## Ensure => absent does not delete the extracted file.
    archive { '/var/tmp/imanager.tar.xz':
      ensure       => $ensure,
      extract      => true,
      extract_path => '/usr/src',
      source       => "${ccs_pkgarchive}/${src}",
      creates      => "/usr/src/${dest}",
      cleanup      => true,
    }


    ccs_hcu::dkms { 'imanager':
      ensure  => $ensure,
      module  => $module,
      version => $version,
      archive => '/var/tmp/imanager.tar.xz',
    }


    $ptitle = regsubst($title, '::.*', '', 'G')

    $conf = 'imanager.conf'

    file { "/etc/modules-load.d/${conf}":
      ensure => $ensure,
      source => "puppet:///modules/${ptitle}/${conf}",
    }


    $exec = '/usr/local/libexec/imanager-init'

    file { $exec:
      ensure => $ensure,
      source => "puppet:///modules/${ptitle}/${basename($exec)}",
      mode   => '0755',
    }


    if $ensure == absent {
      service { 'imanager':
        ensure => stopped,
        enable => false,
      }
    }


    $service = 'imanager.service'

    file { "/etc/systemd/system/${service}":
      ensure  => $ensure,
      content => epp("${ptitle}/${service}.epp", {'exec' => $exec}),
    }


    if $ensure == present {
      ensure_resources('group', {'gpio' => {'ensure' => 'present'}})

      exec { 'usermod ccs imanager':
        path    => ['/usr/sbin', '/usr/bin'],
        command => 'usermod -a -G gpio ccs',
        unless  => 'sh -c "groups ccs | grep -q gpio"',
        require => Group['gpio'],
      }
    }


    if $ensure == present {
      ## $exec fails if there is no imanager interface.
      service { 'imanager':
        ensure => running,
        enable => true,
      }
    }

  }

}
