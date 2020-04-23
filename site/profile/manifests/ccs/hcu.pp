class profile::ccs::hcu {

  class { 'profile::ccs::power': ensure => present }

  include profile::ccs::canbus
  include profile::ccs::vldrive
  include profile::ccs::imanager
  include profile::ccs::filter_changer

}
