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

  ## Use first mountpoint that exists, else /home/mysql. TODO hiera?
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
    ## Remove some dubious defaults, eg: anonymous user, test database.
    remove_default_accounts => true,
    restart                 => false,
    service_enabled         => true,
    service_manage          => true,
    options                 => $options,
  }



  if empty($password) {
    ## This only happens at slac. Elsewhere, we use private hiera.
    $ccs_dbarchive = lookup('ccs_dbarchive', String)
    ## Note this reads the file on the master, which is ok.
    ## FIXME this required file to be world-readable, why?
    $db_password = strip(file("${ccs_dbarchive}/ccsdbpasswd"))
  } else {
    $db_password = $password
  }


  if $database and $db_password {
    ## Create empty db called (eg) comcamdbprod;
    ## add ccs account with all privs on that db;
    ## TODO: localdb -u to create tables?
    mysql::db { $database:
      user     => 'ccs',
      password => $db_password,
      ## TODO when doing this by hand, we used both ccs@% and ccs@localhost.
      host     => '%',
      grant    => 'ALL',
      ## Module defaults to 'utf8', 'utf8_general_ci'.
      ## It will modify an existing database.
      ## There does not seem to be a way to specify "use server default".
      charset  => 'latin1',
      collate  => 'latin1_swedish_ci',
    }
  }

}
