class ccs_sal::service {

  $setupfile = '/etc/ccs/setup-sal5'

  $epp_vars = {
    desc    => 'OpenSpliceDDS daemons',
    user    => 'ccs',
    group   => 'ccs',
    workdir => '/home/ccs',
    start   => "/bin/bash -c 'source ${setupfile} && \$OSPL_HOME/bin/ospl -f start'",
    stop    => "/bin/bash -c 'source ${setupfile} && \$OSPL_HOME/bin/ospl stop'",
  }

  $service = 'opensplice'

  systemd::unit_file { "${service}.service":
    content => epp("${module_name}/${service}.service.epp", $epp_vars),
  }
  -> service { $service:
    enable => true,
  }

}
