## Setup the iManager module.

class ccs_imanager {

  ensure_packages(['dkms', 'gcc', 'make'])


  $module = lookup('ccs_imanager::module')
  $version = lookup('ccs_imanager::version')
  $pkgarchive = lookup('pkgarchive', String)
  ## Patched version with dkms.conf and fixed Makefile.
  $src = "${module}-${version}_dkms.tar.xz"
  $dest = "${module}-${version}"

  archive { '/tmp/imanager.tar.xz':
    ensure => present,
    extract => true,
    extract_path => '/usr/src',
    source => "${pkgarchive}/${src}",
    creates => "/usr/src/${dest}",
    cleanup => true,
    notify => Exec['dkms'],
  }


  ## TODO add a dkms helper script, or check forge.
  exec { 'dkms':
    path => ['/usr/sbin', '/usr/bin'],
    command => "sh -c \"dkms add -m ${module} -v ${version} && dkms build -m ${module} -v ${version} && dkms install -m ${module} -v ${version}\"",
    unless => "sh -c \"dkms status | grep -q ^${module}\"",
  }


  $conf = 'imanager.conf'

  file { "/etc/modules-load.d/${conf}":
    ensure => present,
    source => "puppet:///modules/${title}/${conf}",
  }


  $exec = '/usr/local/libexec/imanager-init'

  file { "${exec}":
    ensure => present,
    source => "puppet:///modules/${title}/${basename($exec)}",
    mode => '0755',
  }


  $service = 'imanager.service'

  file { "/etc/systemd/system/${service}":
    ensure => file,
    content => epp("${title}/${service}.epp", {'exec' => $exec}),
  }


  group { 'gpio':
    ensure => present,
  }

  ## FIXME
  exec { 'usermod ccs':
    path => ['/usr/sbin', '/usr/bin'],    
    command => 'usermod -a -G gpio ccs',
    unless => 'sh -c "groups ccs | grep -q gpio"',
  }


  ## $exec fails if there is no imanager interface.
  service { 'imanager':
    ensure => running,
    enable => true,
  }


}
