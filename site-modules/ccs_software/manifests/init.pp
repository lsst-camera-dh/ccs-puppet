class ccs_software {

  ## TODO ensure_resources for ccs user?

  $dirs = lookup('ccs_software::dirs', Hash)

  class { 'ccs_software::dirs':
    dirs => $dirs,
  }

  class { 'ccs_software::etc':
    dir => $dirs['etc']['path'],
  }

  class { 'ccs_software::git':
    dir => $dirs['ccsadm']['path'],
  }

  include ccs_software::scripts

}
