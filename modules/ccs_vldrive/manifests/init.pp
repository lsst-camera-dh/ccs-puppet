## @summary
##   Add (or remove) the lion vldrive module.
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent') module.
class ccs_vldrive (String $ensure = 'nothing') {

  if $ensure =~ /(present|absent)/ {

    ensure_packages(['xz', 'tar', 'dkms', 'gcc', 'make', 'kernel-devel'])

    $module = lookup('ccs_vldrive::module')
    $version = lookup('ccs_vldrive::version')
    $pkgarchive = lookup('pkgarchive', String)
    ## Patched version with dkms.conf and dkms_build.sh script.
    $src = "${module}-${version}_dkms.tar.xz"
    $dest = "${module}-${version}"

    ## Ensure => absent does not delete the extracted file.
    archive { '/tmp/vldrive.tar.xz':
      ensure       => present,
      extract      => true,
      extract_path => '/usr/src',
      source       => "${pkgarchive}/${src}",
      creates      => "/usr/src/${dest}",
      cleanup      => true,
    }


    ## TODO add a dkms helper script, or check forge.
    case $ensure {
      present: {
        exec { 'dkms install vldrive':
          path      => ['/usr/sbin', '/usr/bin'],
          command   => @("CMD"/L),
            sh -c 'dkms add -m ${module} -v ${version} && \
            dkms build -m ${module} -v ${version} && \
            dkms install -m ${module} -v ${version}'
            | CMD
          unless    => "sh -c 'dkms status | grep -q ^${module}'",
          subscribe => Archive['/tmp/vldrive.tar.xz'],
        }
      }
      absent: {
        exec { 'dkms remove vldrive':
          path    => ['/usr/sbin', '/usr/bin'],
          command => "dkms remove -m ${module} -v ${version} --all",
          onlyif  => "sh -c 'dkms status | grep -q ^${module}'",
        }
      }
      default: { }
    }


    $modload = 'vldrive.conf'

    file { "/etc/modules-load.d/${modload}":
      ensure => $ensure,
      source => "puppet:///modules/${title}/${modload}",
    }


    ## cat /sys/module/vldrive/parameters/FPGA_BASE should return 3200.
    $modconf = 'vldrive.conf'

    file { "/etc/modprobe.d/${modconf}":
      ensure => $ensure,
      source => "puppet:///modules/${title}/modprobed-${modconf}",
    }


    $lib = 'libVL_OSALib.1.5.0.so'

    file { "/usr/local/lib/${lib}":
      ensure => $ensure,
      source => "/usr/src/${dest}/vl_${lib}",
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


    ## FIXME
    exec { 'groupadd gpio vldrive':
      path    => ['/usr/sbin', '/usr/bin'],
      command => 'groupadd gpio',
      unless  => 'getent group gpio',
    }

    exec { 'usermod ccs vldrive':
      path    => ['/usr/sbin', '/usr/bin'],
      command => 'usermod -a -G gpio ccs',
      unless  => 'sh -c "groups ccs | grep -q gpio"',
    }


    ## Set /dev/vldrive: group gpio, mode 660 (default is root 600).
    $udev = '99-vldrive.rules'

    file { "/etc/udev/rules.d/${udev}":
      ensure => $ensure,
      source => "puppet:///modules/${title}/${udev}",
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
