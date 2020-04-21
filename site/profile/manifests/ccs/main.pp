class profile::ccs::main {

  class { 'selinux':
    mode => 'permissive',
  }

  service {['initial-setup-graphical', 'initial-setup-text']:
    ensure => 'stopped',
    enable => false,
  }

  include profile::ccs::facts

  include profile::ccs::time

  include profile::ccs::firewall

  include profile::ccs::fail2ban

  include profile::ccs::home

  include profile::ccs::root

  include profile::ccs::users

  if $facts['location'] == 'slac' {

    include profile::ccs::chef

    if $facts['native_gpfs'] != 'true' {
      include profile::ccs::autofs        # mounts pkgarchive
    }

    include profile::ccs::kerberos
    include profile::ccs::grub
    include profile::ccs::ssh
  }

  include profile::ccs::packages          # needs pkgarchive

  include profile::ccs::clustershell

  include profile::ccs::dirs

  include profile::ccs::etc

  include profile::ccs::git

  include profile::ccs::profile_d

  include profile::ccs::scripts

  include profile::ccs::sudo

  include profile::ccs::sysctl

  include profile::ccs::jdk8

  include profile::ccs::desktop

  include profile::ccs::monit

  include profile::ccs::mrtg

  include profile::ccs::graphical

  include profile::ccs::network

  include profile::ccs::autologin

  include profile::ccs::database

  include profile::ccs::canbus

  include profile::ccs::vldrive

  include profile::ccs::imanager

  include profile::ccs::filter_changer

  include profile::ccs::power

  include profile::ccs::jdk11

  include profile::ccs::nvidia

}
