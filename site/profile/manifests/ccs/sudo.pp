## FIXME fails if pre-existing files have mode != 0440

class profile::ccs::sudo {

  class { 'sudo':
    ## Leave non-managed files in /etc/sudoers.d/ alone:
    purge               => false,
    # Leave /etc/sudoers alone:
    config_file_replace => false,
    validate_single     => true,
    #  delete_on_error     => false,
  }


  $sudoers = lookup('profile::ccs::sudoers',Array[String], undef, [])

  $sudoers.each |String $user| {
    sudo::conf { $user:
      priority => 50,
      content  => "${user} ALL=ALL",
    }
  }


  $group = 'lsst-ccs'

  $content1 = "%${group} ALL = (ccs) ALL"
  if $facts['location'] == 'slac' {
    $content2 = "\n%${group} ALL = (dh) ALL"
  } else {
    $content2 = ''
  }

  sudo::conf { "group-${group}":
    priority => 10,
    content  => "${content1}${content2}",
  }


  $ptitle = regsubst($title, '::', '/', 'G')

  ## TODO replace this with puppet.
  $file = 'ccs-sudoers-services'

  file { "/etc/cron.hourly/${file}":
    ensure => present,
    source => "puppet:///modules/${ptitle}/${file}",
    mode   => '0755',
  }

}
