class profile::ccs::scripts {

  $ptitle = regsubst($title, '::', '/', 'G')

  ## FIXME do not assume the home directory location.
  file { '/home/ccs/scripts':
    source  => "puppet:///modules/${ptitle}/install",
    recurse => true,
    purge   => false,
    owner   => 'ccs',
    group   => 'ccs',
    mode    => '0755',
  }

}
