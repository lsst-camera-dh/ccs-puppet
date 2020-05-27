class profile::slac::common {

  class { 'selinux':
    mode => 'permissive',
  }

  service {['initial-setup-graphical', 'initial-setup-text']:
    ensure => 'stopped',
    enable => false,
  }

  ## Make permissions like /tmp.
  if $facts['mountpoints']['/scratch'] {
    file { '/scratch':
      ensure => directory,
      mode   => '1777',
    }
  }

  include profile::slac::time

  include profile::slac::firewall

  include profile::slac::fail2ban

  include profile::slac::root

  include profile::slac::chef

  if $facts['native_gpfs'] != 'true' {
    include profile::slac::autofs        # mounts ccs_pkgarchive
  }

  include profile::slac::dirs

  include profile::slac::kerberos
  include profile::slac::grub
  include profile::slac::ssh

  include profile::slac::sysctl

  include profile::slac::sudo
}
