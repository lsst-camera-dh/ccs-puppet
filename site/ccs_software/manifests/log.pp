class ccs_software::log {

  $ptitle = regsubst($title, '::.*', '', 'G')

  $file = 'ccs-log-compress'

  $archive = $::site ? { 'slac' => 'm', default => 'n', }

  file { "/etc/cron.daily/${file}":
    content => epp("${ptitle}/${file}", {'archive' => $archive}),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }


  $ccslog = 'ccslog'

  file { "/usr/local/bin/${ccslog}":
    ensure => present,
    source => "puppet:///modules/${ptitle}/${ccslog}",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

}
