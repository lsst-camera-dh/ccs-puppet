class ccs_clustershell {

  ensure_packages(['clustershell'])

  $file = '/etc/clustershell/groups.d/local.cfg'
  $src = "${facts['location']}-local.cfg"

  file { $file:
      ensure => present,
      source => "puppet:///modules/${title}/${src}",
    }

}
