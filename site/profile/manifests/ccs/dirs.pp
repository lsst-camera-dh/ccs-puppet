## @summary
##   Create common ccs directories.
##
## @param dirs
##   Hash, with each value a hash of file attributes

class profile::ccs::dirs (Hash $dirs) {

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


  ## Make permissions like /tmp.
  if $facts['mountpoints']['/scratch'] {
    file { '/scratch':
      ensure => directory,
      mode   => '1777',
    }
  }


}
