## @summary
## @param users
##   Optional array of users to have sudo ALL privs.

class profile::slac::sudo (Array[String] $users = []) {

  ## NB fails if pre-existing files have mode != 0440
  class { 'sudo':
    ## Leave non-managed files in /etc/sudoers.d/ alone:
    purge               => false,
    # Leave /etc/sudoers alone:
    config_file_replace => false,
    validate_single     => true,
    #  delete_on_error     => false,
  }


  $users.each |String $user| {
    sudo::conf { $user:
      priority => 50,
      content  => "${user} ALL=ALL",
    }
  }


  $group = 'lsst-ccs'

  $content1 = "%${group} ALL = (ccs) ALL"
  if $facts['site'] == 'slac' {
    $content2 = "\n%${group} ALL = (dh) ALL"
  } else {
    $content2 = ''
  }

  sudo::conf { "group-${group}":
    priority => 10,
    content  => "${content1}${content2}",
  }

}
