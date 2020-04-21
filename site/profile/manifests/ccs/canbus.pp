## @summary
##   Add (or remove) the lion canbus module.
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent') module.
class profile::ccs::canbus (String $ensure = 'nothing') {

  $ptitle = regsubst($title, '::', '/', 'G')

  if $ensure =~ /(present|absent)/ {

    ## We still need most of these even if ensure = absent.
    ensure_packages(['xz', 'tar', 'dkms', 'gcc', 'make', 'kernel-devel'])

    $module = lookup('profile::ccs::canbus::module')
    $version = lookup('profile::ccs::canbus::version')
    $pkgarchive = lookup('pkgarchive', String)
    ## Patched version with dkms.conf and fixed driver/Makefile.
    $src = "${module}_V${version}_dkms.tar.xz"
    $lmodule = "${downcase($module)}"
    $dest = "${lmodule}-${version}"

    ## Ensure => absent does not delete the extracted file.
    archive { '/tmp/canbus.tar.xz':
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
        exec { 'dkms install canbus':
          path      => ['/usr/sbin', '/usr/bin'],
          command   => @("CMD"/L),
            sh -c 'dkms add -m ${lmodule} -v ${version} && \
            dkms build -m ${lmodule} -v ${version} && \
            dkms install -m ${lmodule} -v ${version}'
            | CMD
          unless    => "sh -c 'dkms status | grep -q ^${lmodule}'",
          subscribe => Archive['/tmp/canbus.tar.xz'],
        }
      }
      absent: {
        exec { 'dkms remove canbus':
          path    => ['/usr/sbin', '/usr/bin'],
          command => "dkms remove -m ${lmodule} -v ${version} --all",
          onlyif  => "sh -c 'dkms status | grep -q ^${lmodule}'",
        }
      }
      default: { }
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
