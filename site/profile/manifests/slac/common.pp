class profile::slac::common {

  class { 'selinux':
    mode => 'permissive',
  }

  service {['initial-setup-graphical', 'initial-setup-text']:
    ensure => 'stopped',
    enable => false,
  }

  include profile::slac::time

  include profile::slac::firewall

  include profile::slac::fail2ban

  include profile::slac::home

  include profile::slac::root

  include profile::slac::chef

  if $facts['native_gpfs'] != 'true' {
    include profile::slac::autofs        # mounts pkgarchive
  }

  include profile::slac::kerberos
  include profile::slac::grub
  include profile::slac::ssh

}
