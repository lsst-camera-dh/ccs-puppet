class ccs_main {

  ## TODO
  ## mysql module can create database 
  ## Local yum repo

  include ccs_time

  if $facts['location'] == 'slac' {
    include ccs_chef
  }

  include ccs_packages

  include ccs_clustershell

  include ccs_users

  include ccs_dirs

  include ccs_etc

  include ccs_sudo

  if ($facts['location'] == 'slac') and ($facts['native_gpfs'] != 'true') {
    include ccs_autofs
  }

  include ccs_jdk8

  ## FIXME restrict by hostname.
  ## FIXME test is wrong for servers if we have installed graphical stuff.
  if $facts['rpm_gdm'] == 'true' {

    service { 'gdm':
      enable => true,
    }

    exec { 'Set graphical target':
      path    => ['/usr/sbin', '/usr/bin'],
      command => 'systemctl set-default graphical.target',
      unless  => 'sh -c "systemctl get-default | grep -qF graphical.target"',
    }

    package { 'gnome-initial-setup':
      ensure => purged,
    }
  }


  service {['initial-setup-graphical', 'initial-setup-text']:
    ensure => 'stopped',
    enable => false,
  }


  class { 'selinux':
    mode => 'permissive',
  }

  include ccs_firewall

  include ccs_fail2ban

  include ccs_scripts

  class { 'ccs_git':
    ensure => present
  }

  include ccs_profile_d

  include ccs_home

  include ccs_desktop

  include ccs_root

  if $facts['location'] == 'slac' {
    include ccs_kerberos
    include ccs_grub
    include ccs_ssh
  }

  include ccs_monit

  include ccs_mrtg

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


  include ccs_sysctl


  if $::hostname =~ /lsst-(vw|it)01/ {
    class { 'ccs_nvidia':
      install => true,
    }
  }


}
