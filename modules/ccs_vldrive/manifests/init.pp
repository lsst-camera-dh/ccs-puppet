## Set up the vldrive modules on a lion host.

class ccs_vldrive {

  ensure_packages(['dkms', 'gcc', 'make'])


  $module = lookup('ccs_vldrive::module')
  $version = lookup('ccs_vldrive::version')
  $pkgarchive = lookup('pkgarchive', String)
  ## Patched version with dkms.conf and dkms_build.sh script.
  $src = "${module}-${version}_dkms.tar.xz"
  $dest = "${module}-${version}"

  archive { '/tmp/vldrive.tar.xz':
    ensure       => present,
    extract      => true,
    extract_path => '/usr/src',
    source       => "${pkgarchive}/${src}",
    creates      => "/usr/src/${dest}",
    cleanup      => true,
    notify       => Exec['dkms'],
  }


  ## TODO add a dkms helper script, or check forge.
  exec { 'dkms':
    path    => ['/usr/sbin', '/usr/bin'],
    command => @("CMD"/L),
      sh -c 'dkms add -m ${module} -v ${version} && \
      dkms build -m ${module} -v ${version} && \
      dkms install -m ${module} -v ${version}'
      | CMD
    unless  => "sh -c \"dkms status | grep -q ^${module}\"",
  }


  $modload = 'vldrive.conf'

  file { "/etc/modules-load.d/${modload}":
    ensure => present,
    source => "puppet:///modules/${title}/${modload}",
  }


  ## cat /sys/module/vldrive/parameters/FPGA_BASE should return 3200.
  $modconf = 'vldrive.conf'

  file { "/etc/modprobe.d/${modconf}":
    ensure => present,
    source => "puppet:///modules/${title}/modprobed-${modconf}",
  }


  $lib = 'libVL_OSALib.1.5.0.so'

  file { "/usr/local/lib/${lib}":
    ensure => present,
    source => "/usr/src/${dest}/vl_${lib}",
    mode   => '0755',
  }


  $links = ['libVL_OSALib.so', 'libVL_OSALib.so.1']

  $links.each|$link| {
    file { "/usr/local/lib/${link}":
      ensure => 'link',
      target => $lib,
    }
  }


  ## Set /dev/vldrive: group gpio, mode 660 (default is root 600).
  group { 'gpio':
    ensure => present,
  }

  ## FIXME
  exec { 'usermod ccs':
    path    => ['/usr/sbin', '/usr/bin'],
    command => 'usermod -a -G gpio ccs',
    unless  => 'sh -c "groups ccs | grep -q gpio"',
  }


  $udev = '99-vldrive.rules'

  file { "/etc/udev/rules.d/${udev}":
    ensure => present,
    source => "puppet:///modules/${title}/${udev}",
    notify => Exec['udevadm'],
  }

  exec { 'udevadm':
    path        => ['/usr/sbin', '/usr/bin'],
    command     => 'sh -c "udevadm control --reload-rules && udevadm trigger --type=devices --action=change"',
    refreshonly => true,
  }


}
