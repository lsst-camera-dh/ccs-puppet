## @summary
##   Install sql database service.
##
## @param ensure
##   String saying whether to install ('present') or stop ('stopped').
##
## TODO https://forge.puppet.com/puppetlabs/mysql
class ccs_database (String $ensure = 'nothing') {

  if $ensure =~ /(present|stopped)/ {

    ensure_packages(['mariadb-server'])

    ## FIXME use first that exists, else /home/mysql.
    # $datadir = ['/lsst-ir2db01',
    #             '/data',
    #             '/home/mysql'].filter |$value| { find_file($value) }

    $datadir = '/home/mysql'

    file { $datadir:
      ensure => directory,
      owner  => 'mysql',
      group  => 'mysql',
      mode   => '0755',
    }


    $scratch = $facts['mounted_scratch'] ? {'true' => true, default => false}

    $file = 'zzz-lsst-ccs.cnf'

    file { "/etc/my.cnf.d/${file}":
      ensure  => file,
      content => epp(
        "${title}/${file}.epp", {
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
