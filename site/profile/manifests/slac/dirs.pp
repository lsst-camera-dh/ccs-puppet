class profile::slac::dirs {

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
