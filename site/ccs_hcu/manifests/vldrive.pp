## @summary
##   Add (or remove) the lion vldrive module.
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent') module.
class ccs_hcu::vldrive (String $ensure = 'nothing') {

  $ptitle = regsubst($title, '::.*', '', 'G')

  if $ensure =~ /(present|absent)/ {

    ensure_packages(['xz', 'tar'])

    $module = lookup('ccs_hcu::vldrive::module')
    $version = lookup('ccs_hcu::vldrive::version')
    $ccs_pkgarchive = lookup('ccs_pkgarchive', String)
    ## Patched version with dkms.conf and dkms_build.sh script.
    $src = "${module}-${version}_dkms.tar.xz"
    $dest = "${module}-${version}"

    ## Ensure => absent does not delete the extracted file.
    archive { '/var/tmp/vldrive.tar.xz':
      ensure       => $ensure,
      extract      => true,
      extract_path => '/usr/src',
      source       => "${ccs_pkgarchive}/${src}",
      creates      => "/usr/src/${dest}",
      cleanup      => true,
    }


    ccs_hcu::dkms { 'vldrive':
      ensure  => $ensure,
      module  => $module,
      version => $version,
      archive => '/var/tmp/vldrive.tar.xz',
    }


    $modload = 'vldrive.conf'

    file { "/etc/modules-load.d/${modload}":
      ensure => $ensure,
      source => "puppet:///modules/${ptitle}/${modload}",
    }


    ## cat /sys/module/vldrive/parameters/FPGA_BASE should return 3200.
    $modconf = 'vldrive.conf'

    file { "/etc/modprobe.d/${modconf}":
      ensure => $ensure,
      source => "puppet:///modules/${ptitle}/modprobed-${modconf}",
    }


    $lib = 'libVL_OSALib.1.5.0.so'

    $lib_source = $ensure ? {
      present => "/usr/src/${dest}/vl_${lib}",
      default => '/usr/local/lib',
    }

    ## If source does not exist, we get an error even if ensure is absent.
    file { "/usr/local/lib/${lib}":
      ensure => $ensure,
      source => $lib_source,
      mode   => '0755',
    }


    $links = ['libVL_OSALib.so', 'libVL_OSALib.so.1']
    $link_status = $ensure ? { present => 'link', default => 'absent' }

    $links.each|$link| {
      file { "/usr/local/lib/${link}":
        ensure => $link_status,
        target => $lib,
      }
    }


    if $ensure == present {
      ensure_resources('group', {'gpio' => {'ensure' => 'present'}})

      exec { 'usermod ccs vldrive':
        path    => ['/usr/sbin', '/usr/bin'],
        command => 'usermod -a -G gpio ccs',
        unless  => 'sh -c "groups ccs | grep -q gpio"',
        require => Group['gpio'],
      }
    }


    ## Set /dev/vldrive: group gpio, mode 660 (default is root 600).
    $udev = '99-vldrive.rules'

    file { "/etc/udev/rules.d/${udev}":
      ensure => $ensure,
      source => "puppet:///modules/${ptitle}/${udev}",
      notify => Exec['udevadm vldrive'],
    }

    exec { 'udevadm vldrive':
      path        => ['/usr/sbin', '/usr/bin'],
      command     => @("CMD"/L),
        sh -c 'udevadm control --reload-rules && \
        udevadm trigger --type=devices --action=change'
        | CMD
      refreshonly => true,
    }

  }

}
