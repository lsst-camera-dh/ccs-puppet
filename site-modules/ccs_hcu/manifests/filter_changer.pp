## @summary
##   Add (or remove) filter changer device links
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent').
class ccs_hcu::filter_changer (String $ensure = 'absent') {

  $ptitle = regsubst($title, '::.*', '', 'G')

  ## Create /dev/{encoder,motor} symlinks for filter changer hcu.
  $file = '99-usb-serial.rules'

  file { "/etc/udev/rules.d/${file}":
    ensure => $ensure,
    source => "puppet:///modules/${ptitle}/${file}",
    notify => Exec['udevadm filter_changer'],
  }

  exec { 'udevadm filter_changer':
    path        => ['/usr/sbin', '/usr/bin'],
    command     => @("CMD"/L),
      sh -c 'udevadm control --reload-rules && \
      udevadm trigger --type=devices --action=change'
      | CMD
    refreshonly => true,
  }

}
