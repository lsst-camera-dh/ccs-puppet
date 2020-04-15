## @summary
##   Add (or remove) the iManager module.
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent') module.
class ccs_imanager (String $ensure = 'nothing') {

  if $ensure =~ /(present|absent)/ {

    ensure_packages(['xz', 'tar', 'dkms', 'gcc', 'make', 'kernel-devel'])

    $module = lookup('ccs_imanager::module')
    $version = lookup('ccs_imanager::version')
    $pkgarchive = lookup('pkgarchive', String)
    ## Patched version with dkms.conf and fixed Makefile.
    $src = "${module}-${version}_dkms.tar.xz"
    $dest = "${module}-${version}"

    ## Ensure => absent does not delete the extracted file.
    archive { '/tmp/imanager.tar.xz':
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
        exec { 'dkms install imanager':
          path      => ['/usr/sbin', '/usr/bin'],
          command   => @("CMD"/L),
            sh -c 'dkms add -m ${module} -v ${version} && \
            dkms build -m ${module} -v ${version} && \
            dkms install -m ${module} -v ${version}'
            | CMD
          unless    => "sh -c \"dkms status | grep -q ^${module}\"",
          subscribe => Archive['/tmp/imanager.tar.xz'],
        }
      }
      absent: {
        exec { 'dkms remove imanager':
          path    => ['/usr/sbin', '/usr/bin'],
          command => "dkms remove -m ${module} -v ${version} --all",
          onlyif  => "sh -c 'dkms status | grep -q ^${module}'",
        }
      }
      default: { }
    }


    $conf = 'imanager.conf'

    file { "/etc/modules-load.d/${conf}":
      ensure => $ensure,
      source => "puppet:///modules/${title}/${conf}",
    }


    $exec = '/usr/local/libexec/imanager-init'

    file { $exec:
      ensure => $ensure,
      source => "puppet:///modules/${title}/${basename($exec)}",
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
      content => epp("${title}/${service}.epp", {'exec' => $exec}),
    }


    ## FIXME
    exec { 'groupadd gpio imanager':
      path    => ['/usr/sbin', '/usr/bin'],
      command => 'groupadd gpio',
      unless  => 'getent group gpio',
    }

    exec { 'usermod ccs imanager':
      path    => ['/usr/sbin', '/usr/bin'],
      command => 'usermod -a -G gpio ccs',
      unless  => 'sh -c "groups ccs | grep -q gpio"',
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
