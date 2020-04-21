class profile::ccs::grub {

  ## TODO Augeas?
  exec { 'Prevent console spam from common Dell mice':
    path    => [ '/usr/bin' ],
    unless  => 'grep -q usbhid.quirks /etc/default/grub',
    command => @(CMD/L),
      sed -i "/^GRUB_CMDLINE_LINUX=/ s/\"$/ \
      usbhid.quirks=0x413c:0x301a:0x00000400,0x04ca:0x0061:0x00000400\"/" \
      /etc/default/grub
      | CMD
    notify  => Exec['grub2-mkconfig'],
  }

  if $facts['efi'] {
    $grubfile = '/boot/efi/EFI/centos/grub.cfg'
  } else {
    $grubfile = '/boot/grub2/grub.cfg'
  }

  exec { 'grub2-mkconfig':
    path        => [ '/usr/sbin', '/usr/bin' ],
    command     => "grub2-mkconfig -o ${grubfile}",
    refreshonly => true,
  }


}
