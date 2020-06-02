## @summary
##   Install hcu-specific stuff.
##
## @param quadbox
##   True if this is a quadbox host.
## @param canbus|vldrive|imanager
##   True (or 'present') if need specified module;
##   false (or 'absent') removes it; 'nothing' does nothing.
## @param filter_changer
##   True (or 'present') to install; false (or 'absent') to remove.

class ccs_hcu (
  Boolean $quadbox = false,
  Variant[Boolean,String] $canbus = false,
  Variant[Boolean,String] $vldrive = false,
  Variant[Boolean,String] $imanager = false,
  Variant[Boolean,String] $filter_changer = false,
) {

  $opts0 = {
    'canbus'         => $canbus,
    'vldrive'        => $vldrive,
    'imanager'       => $imanager,
    'filter_changer' => $filter_changer,
  }

  $opts1 = $opts0.map |$key, $value| {
    [$key, $value ? {
      true    => 'present',
      false   => 'absent',
      default => $value,
    }]}

  $opts = Hash(flatten($opts1))


  class { 'ccs_hcu::power':
    ensure  => present,
    quadbox => $quadbox,
  }

  class { 'ccs_hcu::canbus':
    ensure => $opts['canbus'],
  }

  class { 'ccs_hcu::vldrive':
    ensure => $opts['vldrive'],
  }

  class { 'ccs_hcu::imanager':
    ensure => $opts['imanager'],
  }

  class { 'ccs_hcu::filter_changer':
    ensure => $opts['filter_changer'],
  }

}
