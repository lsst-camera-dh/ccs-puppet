class ccs_hcu {

  class { 'ccs_hcu::power': ensure => present }

  include ccs_hcu::canbus
  include ccs_hcu::vldrive
  include ccs_hcu::imanager
  include ccs_hcu::filter_changer

}
