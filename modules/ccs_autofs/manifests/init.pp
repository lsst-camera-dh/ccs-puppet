class ccs_autofs {

  ensure_packages(['autofs', 'nfs-utils'])


  ## Not strictly necessary since nfs paths are also pruned,
  ## but this may avoid some hangs when the server does not respond.
  exec { 'Exclude gpfs from updatedb.conf':
    path    => [ '/usr/bin' ],
    unless  => 'grep -q "PRUNEPATHS.*/gpfs " /etc/updatedb.conf',
    command => 'sed -i "s|^\(PRUNEPATHS = \"\)|\1/gpfs |" /etc/updatedb.conf',
  }


  ## It would be nicer to only use eg "fs1" (rather than "fs1/g") here,
  ## but it seems as if the server is not set up to allow that.
  ## (Maybe this is an nfs3 issue?)
  file { '/etc/auto.gpfs':
    ensure => file,
    source => "puppet:///modules/${title}/auto.gpfs",
    notify => Service['autofs'],
  }

  ## TODO unmount any pre-existing static mounts.


  ## Need vers=3 to avoid problems with (bonded) wifi on aios.
#  case $hostname {
#    /-aio\d+/: {
#      $options = '  vers=3'
#    }
#    ## Some hosts need vers=4.0 (to avoid lsst-ss01 hangs)?
#    ## Some older autofs will reject the ".", so use "vers=4".
#    ## https://bugzilla.redhat.com/show_bug.cgi?id=1486035
#    default: {
#      $options = ''
#    }
#  }

  ## 201916: Avoid Ganesha nfsv4 lease bug. SLAC INC0239891.
  $options = '  vers=3'

  $file = 'gpfs.autofs'

  file { "/etc/auto.master.d/${file}":
    ensure  => file,
    content => epp("${title}/${file}.epp", {'options' => $options}),
    notify  => Service['autofs'],
  }


  ## Remove "sss" so as to avoid a bunch of SLAC NFS that we don't want.
  ## Disabled: this file is managed by Chef, so avoid conflicts.
#  exec { 'Modify nsswitch.conf automount':
#    path => [ '/usr/bin' ],
#    onlyif => 'grep -q "^automount:.*sss" /etc/nsswitch.conf',
#    command => 'sed -i "s/^automount:.*/automount:      files/" /etc/nsswitch.conf',
#  }


  service { 'autofs':
    ensure => running,
    enable => true,
  }

}
