class ccs_time {

  include timezone
  ## TODO: hwclock -w if we changed anything.

  ensure_packages(['chrony'])

  service { 'chronyd':
    ensure => stopped,
    enable => false,
  }

}
