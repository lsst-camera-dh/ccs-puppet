## @summary
##   Install sql database service.
##
## @param ensure
##   String saying whether to install ('present') or stop ('stopped').
##
## TODO https://forge.puppet.com/puppetlabs/mysql
class profile::ccs::database (String $ensure = 'nothing') {

  if $ensure =~ /(present|stopped)/ {

    ensure_packages(['mariadb-server'])

    ## Use first mountpoint that exists, else /home/mysql.
    $datadirs = [
      '/lsst-ir2db01',
      '/data',
      '/home'
    ].filter |$disk| { $facts['mountpoints'][$disk] }

    $datadir0 = pick($datadirs[0], '/home')
    $datadir = "${datadir0}/mysql"

    file { $datadir:
      ensure => directory,
      owner  => 'mysql',
      group  => 'mysql',
      mode   => '0755',
    }


    $ptitle = regsubst($title, '::', '/', 'G')

    $scratch = $facts['mountpoints']['/scratch'] ? {undef => false, default => true}

    $file = 'zzz-lsst-ccs.cnf'

    file { "/etc/my.cnf.d/${file}":
      ensure  => file,
      content => epp(
        "${ptitle}/${file}.epp", {
          'datadir' => $datadir,
          'scratch' => $scratch
        }),
    }

    case $ensure {
      present: {
        $running = 'running'
        $enable = true
      }
      default: {
        $running = 'stopped'
        $enable = false
      }
    }

    service { 'mariadb':
      ensure => $running,
      enable => $enable,
    }

  }
}
