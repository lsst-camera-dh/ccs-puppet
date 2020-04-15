## TODO
## mysql module can create database 
## Local yum repo
class ccs_main {

  class { 'selinux':
    mode => 'permissive',
  }

  service {['initial-setup-graphical', 'initial-setup-text']:
    ensure => 'stopped',
    enable => false,
  }

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

  class { 'ccs_git':
    ensure => present,          # present or latest
  }

  include ccs_profile_d

  include ccs_scripts

  include ccs_sudo

  include ccs_sysctl

  include ccs_jdk8

  include ccs_desktop

  include ccs_monit

  include ccs_mrtg

  if $facts['role'] =~ /(desktop|hcu)/ {
    include ccs_graphical
  }

  if $::hostname =~ /lsst-(dc0[1236]|ir2daq01)/ {
    class {'ccs_network':
      daq_interface => $facts['daq_interface'],
    }
  }

  if $::hostname =~ /-vw\d+/ {
    include ccs_autologin
  }

  if $facts['role'] == 'database' {
    class { 'ccs_database':
      install => true,
    }
  }

  if $::hostname =~ /(-fcs\d+|lsst-lion18)/ {
    include ccs_canbus
  }

  ## FIXME what are the right hosts for this?
  if $::hostname =~ /lsst-lion(09|1[05])/ {
    include ccs_vldrive
  }

  ## FIXME what are the right hosts for this?
  if $::hostname =~ /lsst-uno11/ {
    include ccs_imanager
  }

  ## FIXME what are the right hosts for this?
  if $::hostname =~ /(lsst-un06|comcam-hcu03)/ {
    include ccs_filter_changer
  }


  if $::hostname =~ /lsst-lion0[2-5]/ {
    $quadbox = true
  } else {
    $quadbox = false
  }

  if $facts['role'] == 'hcu' {
    class { 'ccs_power':
      install => true,
      quadbox => $quadbox,
    }
  }


  if $::hostname == 'lsst-vw01' {
    class { 'ccs_jdk11':
      install => true,
    }
  }

  if $::hostname =~ /lsst-(vw|it)01/ {
    class { 'ccs_nvidia':
      install => true,
    }
  }


}
