class ccs_filter_changer {

  ## Create /dev/{encoder,motor} symlinks for filter changer hcu.
  $file = '99-usb-serial.rules'

  file { "/etc/udev/rules.d/${file}":
    ensure => present,
    source => "puppet:///modules/${title}/${file}",
    notify => Exec['udevadm'],
  }

  exec { 'udevadm':
    path => ['/usr/sbin', '/usr/bin'],
    command => 'sh -c "udevadm control --reload-rules && udevadm trigger --type=devices --action=change"',
    refreshonly => true,
  }

}
