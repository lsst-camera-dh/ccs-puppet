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

  include ccs_software::desktop

  include ccs_software::jdk8

  include ccs_software::maven

  ## LSST does this via a profile:ccs, so moved to profile::slac.
  #include ccs_software::sysctl

  include ccs_software::scripts

  include ccs_software::log

}
