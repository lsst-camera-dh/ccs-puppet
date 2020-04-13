class ccs_database ( Boolean $install = true ) {

  ensure_packages(['mariadb-server'])

  ## FIXME use first that exists, else /home/mysql.
  # $datadir = ['/lsst-ir2db01',
  #             '/data',
  #             '/home/mysql'].filter |$value| { find_file($value) }

  $datadir = '/home/mysql'

  file { "${datadir}":
    ensure => directory,
    owner => 'mysql',
    group => 'mysql',
    mode => '0755',
  }


  ## FIXME this runs on master
#  $scratch = find_file('/scratch') ? { undef => false, default => true }
  $scratch = false;

  $file = 'zzz-lsst-ccs.cnf'

  file { "/etc/my.cnf.d/${file}":
    ensure => file,
    content => epp("${title}/${file}.epp",
                   {'datadir' => $datadir, 'scratch' => $scratch}),
  }


  service { 'mariadb':
    ensure => running,
    enable => true,
  }


  ## TODO https://forge.puppet.com/puppetlabs/mysql

}
