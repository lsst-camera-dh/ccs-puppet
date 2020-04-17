class ccs_main {

  class { 'selinux':
    mode => 'permissive',
  }

  service {['initial-setup-graphical', 'initial-setup-text']:
    ensure => 'stopped',
    enable => false,
  }

  include ccs_facts

  include ccs_time

  include ccs_firewall

  include ccs_fail2ban

  include ccs_home

  include ccs_root

  include ccs_users

  if $facts['location'] == 'slac' {

    include ccs_chef

    if $facts['native_gpfs'] != 'true' {
      include ccs_autofs        # mounts pkgarchive
    }

    include ccs_kerberos
    include ccs_grub
    include ccs_ssh
  }

  include ccs_packages          # needs pkgarchive

  include ccs_clustershell

  include ccs_dirs

  include ccs_etc

  include ccs_git

  include ccs_profile_d

  include ccs_scripts

  include ccs_sudo

  include ccs_sysctl

  include ccs_jdk8

  include ccs_desktop

  include ccs_monit

  include ccs_mrtg

  include ccs_graphical

  include ccs_network

  include ccs_autologin

  include ccs_database

  include ccs_canbus

  include ccs_vldrive

  include ccs_imanager

  include ccs_filter_changer

  include ccs_power

  include ccs_jdk11

  include ccs_nvidia

}
