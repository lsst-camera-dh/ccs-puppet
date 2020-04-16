## @summary
##   Add settings for network interfaces.
##
## @param daq_interface
##   String naming the DAQ network interface; or true to detect it; or
##   false if none.

class ccs_network (Variant[Boolean,String] $daq_interface = false) {

  if $daq_interface {

    ## Normally the interface is "lsst-daq", but not always (eg lsst-dc02).
    ## TODO discover it?
    ## Could check for an interface connected to 192.168.100.1?
    $idefault = 'p3p1'
    $imaybe = 'lsst-daq'

    ## lsst-daq if exists, else p3p1.
    $interface0 = $facts['networking']['interfaces'][$imaybe] ? {
      undef   => $idefault,
      default => $imaybe,
    }

    $interface1 = $daq_interface ? {
      String  => $daq_interface,
      default => $interface0 ,
    }

    ## Note: asked not to modify DAQ network interfaces.
    $interface = "DISABLED-${interface1}"

    $file = '30-ethtool'

    file { "/etc/NetworkManager/dispatcher.d/${file}":
      ensure  => file,
      content => epp("${title}/${file}", {'interface' => $interface}),
      mode    => '0755',
    }
  }

}
