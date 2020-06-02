## @summary
##   Create common ccs directories.
##
## @param dirs
##   Hash, with each value a hash of file attributes

class ccs_software::dirs (Hash $dirs) {

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

}
