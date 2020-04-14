class ccs_autologin {

  exec { 'Auto-login for graphical ccs user':
    path    => ['/usr/bin'],
    unless  => 'grep -q ^AutomaticLogin /etc/gdm/custom.conf',
    command => "sed -i '/^\[daemon.*/a\
AutomaticLogin=ccs\\\n\
AutomaticLoginEnable=true' /etc/gdm/custom.conf",
  }

}
