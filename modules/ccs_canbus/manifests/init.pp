## Setup the canbus module on a lion host.

class ccs_canbus {

  ensure_packages(['dkms', 'gcc', 'make'])


  $module = lookup('ccs_canbus::module')
  $version = lookup('ccs_canbus::version')
  $pkgarchive = lookup('pkgarchive', String)
  ## Patched version with dkms.conf and fixed driver/Makefile.
  $src = "${module}_V${version}_dkms.tar.xz"
  $lmodule = "${downcase($module)}"
  $dest = "${lmodule}-${version}"

  archive { '/tmp/canbus.tar.xz':
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
      sh -c 'dkms add -m ${lmodule} -v ${version} && \
      dkms build -m ${lmodule} -v ${version} && \
      dkms install -m ${lmodule} -v ${version}'
      | CMD
    unless  => "sh -c \"dkms status | grep -q ^${lmodule}\"",
  }


  $conf = 'canbus.conf'

  file { "/etc/modules-load.d/${conf}":
    ensure => present,
    source => "puppet:///modules/${title}/${conf}",
  }


  $exec = '/usr/local/libexec/canbus-init'

  file { $exec:
    ensure => present,
    source => "puppet:///modules/${title}/${basename($exec)}",
    mode   => '0755',
  }


  $service = 'canbus.service'

  file { "/etc/systemd/system/${service}":
    ensure  => file,
    content => epp("${title}/${service}.epp", {'exec' => $exec}),
  }


  ## $exec fails if there is no canbus interface.
  service { 'canbus':
    ensure => running,
    enable => true,
  }


}
