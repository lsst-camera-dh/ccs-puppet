## @summary
##   Add settings for network interfaces.
##
## @param daq_ethtool
##   Boolean, true if need DAQ ethtool settings.

class profile::ccs::network (Boolean $daq_ethtool = false) {

  if $daq_ethtool {
    ## Note: asked not to modify DAQ network interfaces.
    $interface = "DISABLED-${profile::ccs::facts::daq_interface}"

    $file = '30-ethtool'

    file { "/etc/NetworkManager/dispatcher.d/${file}":
      ensure  => file,
      content => epp("${title}/${file}", {'interface' => $interface}),
      mode    => '0755',
    }
  }

}
