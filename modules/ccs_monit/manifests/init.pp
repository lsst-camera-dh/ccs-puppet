class ccs_monit {

  ensure_packages(['monit', 'freeipmi'])

  ## Not sure if monit creates this...
  file { '/var/monit':
    ensure => directory,
  }


  ## Change check interval from 30s to 5m.
  ## TODO? add "read-only" to the allow line?
  file_line { 'Change monit interval':
    path   => '/etc/monitrc',
    match  => '^set daemon',
    line   => 'set daemon  300  # check services at 300 seconds intervals',
    notify => Service['monit']
  }


  $monitd = '/etc/monit.d'
  ## TODO add another email address in case slack is down.
  $mailhost = lookup('mailhost', String)
  $alert = lookup('ccs_monit::alert', String)


  $alertfile = 'alert'
  file { "${monitd}/${alertfile}":
    ensure  => file,
    content => epp(
      "${title}/${alertfile}.epp",
      {'mailhost' => $mailhost, 'alert' => $alert}
    ),
  }


  ## system:
  ## Note that the use of "per core" requires monit >= 5.26.
  ## As of 2019/09, the epel7 version is 5.25.
  ## This requires us to install a newer version in /usr/local/bin,
  ## and modify the service file, but it does mean the config file can
  ## be identical for all hosts.
  ## swap warning is not very useful, since Linux doesn't usually free swap.
  ## Maybe it should just be removed?
  ##
  ## We are using uptime to detect reboots. It also alerts on success.
  ## This could be suppressed with:
  ##  else if succeeded exec "/bin/false"
  ## but that means uptime is always in failed state.
  ##
  ## FIXME disable uptime alert on vi03/04.
  $files = ['config', 'system']
  $files.each |$file| {
    file { "${monitd}/${file}":
      ensure => present,
      source => "puppet:///modules/${title}/${file}",
    }
  }


  ## Ignoring: /boot, and in older slac installs: /scswork, /usr/vice/cache.
  ## vi do not have separate /tmp.
  ## dc nodes have /data.
  ## Older installs have separate /opt /scratch /var.
  ## Newer ones have /home instead.
  ## TODO loop over mount points instead?
  ## Can also do IO rates.
  $disks = {
    'root'    => '/',
    'tmp'     => '/tmp',
    'home'    => '/home',
    'data'    => '/data',
    'opt'     => '/opt',
    'var'     => '/var',
    'scratch' => '/scratch',
    'lsst-ir2db01' => '/lsst-ir2db01',
  }.filter|$key,$value| { $facts['mountpoints'][$value] }

  $disk = 'disks'
  file { "${monitd}/${disk}":
    ensure  => file,
    content => epp("${title}/${disk}.epp", {'disks' => $disks}),
  }


  ## Alert if a client loses gpfs.
  if $facts['native_gpfs'] == 'true' {
    $gpfse = 'gpfs-exists'
    file { "${monitd}/${gpfse}":
      ensure => present,
      source => "puppet:///modules/${title}/${gpfse}",
    }
  }


  ## Check gpfs capacity.
  if $::hostname =~ /lsst-it01/ {
    $gpfs = 'gpfs'
    file { "${monitd}/${gpfs}":
      ensure => present,
      source => "puppet:///modules/${title}/${gpfs}",
    }
  }


  ## TODO move to hiera and use for eg clustershell too.
  case $::hostname {
    /lsst-it01/: {
      ## Excluding lions and unos, which often go up and down.
      $hosts = ['lsst-ir2daq01', 'lsst-ir2db01', 'lsst-mcm',
                'lsst-ss01', 'lsst-ss02', 'lsst-vs01', 'lsst-vw01',
                'lsst-vw02', 'lsst-dc01', 'lsst-dc02', 'lsst-dc03',
                'lsst-dc04', 'lsst-dc05', 'lsst-dc06', 'lsst-dc07',
                'lsst-dc08', 'lsst-dc09', 'lsst-dc10']
    }
    /comcam-fp01/: {
      $hosts = ['comcam-db01', 'comcam-dc01', 'comcam-mcm',
                'comcam-vw01', 'comcam-hcu03', 'comcam-lion01',
                'comcam-lion02', 'comcam-lion03', 'pathfinder-lion01']
    }
    default: {
      $hosts = false
    }
  }

  if $hosts {
    $hfile = 'hosts'
    file { "${monitd}/${hfile}":
      ensure  => file,
      content => epp("${title}/${hfile}.epp", {'hosts' => $hosts}),
    }
  }


  if $::hostname =~ /-mcm/ {
    $itemp = 'inlet-temp'
    file { "${monitd}/${itemp}":
      ensure => present,
      source => "puppet:///modules/${title}/${itemp}",
    }

    $etemp = 'monit_inlet_temp'
    file { "/usr/local/bin/${etemp}":
      ensure => present,
      source => "puppet:///modules/${title}/${etemp}",
      mode   => '0755',
    }
  }


  ## TODO try to automatically fix netspeed?
  if $facts['role'] != 'virt' {
    $main_interface = $ccs_facts::main_interface
    $nfile = 'network'
    file { "${monitd}/${nfile}":
      ensure  => file,
      content => epp(
        "${title}/${nfile}.epp",
        {'interface' => $main_interface}
      ),
    }
  }


  $netspeed = 'monit_netspeed'
  file { "/usr/local/bin/${netspeed}":
    ensure => present,
    source => "puppet:///modules/${title}/${netspeed}",
    mode   => '0755',
  }


  if $::hostname !~ /-(uno|lion|hcu|aio|lt|vw|vi)\d/ {

    $hwraid = 'hwraid'
    file { "${monitd}/${hwraid}":
      ensure => present,
      source => "puppet:///modules/${title}/${hwraid}",
    }

    ## Needs the raid utility (eg perccli64) to be installed separately.
    $hexe = 'monit_hwraid'
    file { "/usr/local/bin/${hexe}":
      ensure => present,
      source => "puppet:///modules/${title}/${hexe}",
      mode   => '0755',
    }
  }


  $service = '/etc/systemd/system/monit.service'
  exec { 'Create monit.service':
    path    => ['/usr/bin'],
    command => "sh -c \"sed 's|/usr/bin/monit|/usr/local/bin/monit|g' /usr/lib/systemd/system/monit.service > ${service}\"",
    creates => $service,
  }


  ## Note that we configure this monit with --prefix=/usr so that
  ## it consults /etc/monitrc, and install just the binary by hand.
  $exe = 'monit'
  $pkgarchive = lookup('pkgarchive',String)
  file { "/usr/local/bin/${exe}":
    ensure => present,
    source => "${pkgarchive}/${exe}",
    mode   => '0755',
  }


  service { 'monit':
    ensure => running,
    enable => true,
  }


}
