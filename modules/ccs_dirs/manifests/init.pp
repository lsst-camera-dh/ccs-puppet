class ccs_dirs (String $etc, String $opt, String $ccs,
                String $adm, String $log) {

  file { $etc:
    ensure => 'directory',
    owner  => 'root',
    group  => 'ccs',
    mode   => '2775',
  }

  file { $opt:
    ensure => directory
  }

  file { [$ccs , $adm]:
    ensure => 'directory',
    owner  => 'ccs',
    group  => 'ccs',
    mode   => '0755',
  }

  file { $log:
    ensure => 'directory',
    owner  => 'root',
    group  => 'ccs',
    mode   => '2777',
  }

  file { '/lsst':
    ensure => 'link',
    target => $opt,
  }


  if $facts['location'] == 'slac' {

    file { '/lnfs':
      ensure => directory
    }

    file { '/lnfs/lsst':
      ensure => 'link',
      target => '/gpfs/slac/lsst/fs2/u1',
    }

    ['dh', 'data'].each |$item| {
      file { "/lsst/${item}":
        ensure => 'link',
        target => "/lnfs/lsst/${item}",
      }
    }
  }


  ## Make permissions like /tmp.
  ## TODO improve partitioning scheme.
  if $facts['mounted_scratch'] == 'true' {
    file { '/scratch':
      ensure => directory,
      mode   => '1777',
    }
  }


}
