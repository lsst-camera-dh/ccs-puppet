## Install (default) or remove nvidia driver settings.

class ccs_nvidia ( Boolean $install = true ) {

  ## This takes care of the /etc/kernel/postinst.d/ part,
  ## so long as the nvidia driver is installed with the dkms option.
  ensure_packages(['dkms'])


  $file = 'disable-nouveau.conf'

  file { "/etc/modprobe.d/${file}":
    ensure => $install ? { true => file, default => absent },
    source => "puppet:///modules/${title}/${file}",
  }


  $grub = '/etc/default/grub'

  if $install {
    exec { 'Blacklist nouveau':
      path => [ '/usr/bin' ],
      unless => "grep -q rdblacklist=nouveau ${grub}",
      command => "sed -i '/^GRUB_CMDLINE_LINUX=/ s/\"\$/ rdblacklist=nouveau\"/' ${grub}",
      notify => Exec['grub and dracut'],
    }
  } else {
    exec { 'Unblacklist nouveau':
      path => [ '/usr/bin' ],
      onlyif => "grep -q rdblacklist=nouveau ${grub}",
      command => "sed -i 's/ *rdblacklist=nouveau//' ${grub}",
      notify => Exec['grub and dracut'],
    }
  }


  if $facts['efi'] {
    $grubfile = '/boot/efi/EFI/centos/grub.cfg'
  } else {
    $grubfile = '/boot/grub2/grub.cfg'
  }

  exec { 'grub and dracut':
    path => [ '/usr/sbin', '/usr/bin' ],
    command => "sh -c 'grub2-mkconfig -o ${grubfile} && dracut -f'",
    refreshonly => true,
  }

  ## TODO actually install the driver if possible.
}
