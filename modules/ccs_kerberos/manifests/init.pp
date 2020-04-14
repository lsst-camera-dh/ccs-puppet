class ccs_kerberos {

  ## TODO do not assume the location of the home directory.
  $dir = '/home/ccs/crontabs'

  file { $dir:
    ensure => directory,
    owner  => 'ccs',
    group  => 'ccs',
  }


  $exe = "${dir}/update-k5login"

  file { $exe:
    ensure => present,
    source => "puppet:///modules/${title}/${basename($exe)}",
    owner  => 'ccs',
    group  => 'ccs',
    mode   => '0755',
  }


  cron { 'cron update-k5login':
    command => $exe,
    user    => 'ccs',
    minute  => [0,15,30,45],
  }

}
