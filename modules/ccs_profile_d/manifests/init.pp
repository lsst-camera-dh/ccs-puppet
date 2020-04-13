class ccs_profile_d {

  ## Environment variables etc.
  ## https://lsstc.slack.com/archives/CCQBHNS0K/p1553877151009500
  $files = 'lsst-ccs.sh'

  file { "/etc/profile.d/${file}":
    source => "puppet:///modules/${title}/${file}",
    ensure => present,
  }

}
