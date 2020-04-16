## @summary
##   Create common ccs directories.
##
## @param dirs
##   Hash, with each value a hash of file attributes

class ccs_dirs (Hash $dirs) {

  $dirs.each | String $dir, Hash $attrs | {
    file { $dir:
      ensure => 'directory',
      *      => $attrs,
    }
  }


  file { '/lsst':
    ensure => 'link',
    target => $dirs['opt']['path'],
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
  if $facts['mountpoints']['/scratch'] {
    file { '/scratch':
      ensure => directory,
      mode   => '1777',
    }
  }


}
