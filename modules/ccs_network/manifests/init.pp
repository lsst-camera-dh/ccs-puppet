## @summary
##   Add settings for network interfaces.
##
## @param daq_interface
##   String naming the DAQ network interface (empty if none).

class ccs_network (String $daq_interface = '') {

  unless empty($daq_interface) {

    ## Note: asked not to modify DAQ network interfaces.
    $interface = "DISABLED-${daq_interface}"

    $file = '30-ethtool'

    file { "/etc/NetworkManager/dispatcher.d/${file}":
      ensure  => file,
      content => epp("${title}/${file}", {'interface' => $interface}),
      mode    => '0755',
    }
  }

}
