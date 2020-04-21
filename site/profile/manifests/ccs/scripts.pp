class profile::ccs::scripts {

  ## FIXME do not assume the home directory location.
  file { '/home/ccs/scripts':
    source  => "puppet:///modules/${title}/install",
    recurse => true,
    purge   => false,
    owner   => 'ccs',
    group   => 'ccs',
    mode    => '0755',
  }

}
