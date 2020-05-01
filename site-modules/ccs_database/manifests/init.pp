## @summary
##   Install sql database service.
##
## @param database
##   String giving name of database to init.
## @param password
##   String giving database password

class ccs_database (
  Optional[String] $database,
  Optional[String] $password = '',
) {

  ## Use first mountpoint that exists, else /home/mysql.
  $datadirs = [
    '/lsst-ir2db01',
    '/data',
    '/home'
  ].filter |$disk| { $facts['mountpoints'][$disk] }

  $datadir0 = pick($datadirs[0], '/home')
  $datadir = "${datadir0}/mysql"
  $socket = "${datadir}/mysql.sock"

  file { $datadir:
    ensure => directory,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0755',
  }


  $options = {
    'mysqld' => {
      'datadir'                 => $datadir,
      'socket'                  => $socket,
      'innodb_buffer_pool_size' => '1G',
      'tmpdir'                  => $facts['mountpoints']['/scratch'] ? {
        undef   => undef,
        default => '/scratch/mysqltmp',
      },
    },
    'client' => {
      'socket' => $socket,
    },
  }

  class {'::mysql::server':
#    package_name            => 'mariadb-server',
#    service_name            => 'mariadb',
    package_ensure          => 'present',
    config_file             => '/etc/my.cnf.d/zzz-lsst-ccs.cnf',
    remove_default_accounts => false,
    restart                 => false,
    service_enabled         => true,
    service_manage          => true,
    options                 => $options,
  }

}
