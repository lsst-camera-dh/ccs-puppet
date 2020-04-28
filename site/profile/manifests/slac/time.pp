class profile::slac::time (Enum['ntp', 'chrony', 'other'] $package = 'chrony') {

  ensure_packages(['chrony', 'ntp'])

  include timezone

  ## If RTC was originally (before including timezone) using local time.
  ## Should not be needed, but is?
  if ($::site == 'slac') and ($facts['rtc_local'] == 'true') {
    exec { 'hwclock -w':
      command => '/usr/sbin/hwclock -w',
    }
  }


  case $package {
    'chrony': {
      service { 'chronyd':
        ensure => running,
        enable => true,
      }
      service { 'ntpd':
        ensure => stopped,
        enable => false,
      }
    }
    'ntp': {
      service { 'chronyd':
        ensure => stopped,
        enable => false,
      }
      service { 'ntpd':
        ensure => running,
        enable => true,
      }
    }
    default: { }
  }

}
