## FIXME fails if pre-existing files have mode != 0440

class ccs_sudo {

  class { 'sudo':
    ## Leave non-managed files in /etc/sudoers.d/ alone:
    purge               => false,
    # Leave /etc/sudoers alone:
    config_file_replace => false,
    validate_single     => true,
    #  delete_on_error     => false,
  }


  $sudoers = lookup('ccs_sudoers',Array[String], undef, [])

  $sudoers.each |String $user| {
    sudo::conf { $user:
      priority => 50,
      content  => "$user ALL=ALL",
    }
  }


  ## FIXME only add dh line at slac.
  $group = 'lsst-ccs'
  sudo::conf { "group-${group}":
    priority => 10,
    content  => "%${group} ALL = (ccs) ALL
%${group} ALL = (dh) ALL",
  }


  ## TODO replace this with puppet.
  $file = 'ccs-sudoers-services'

  file { "/etc/cron.hourly/${file}":
    source => "puppet:///modules/${title}/${file}",
    ensure => present,
    mode => '0755',
  }

}
