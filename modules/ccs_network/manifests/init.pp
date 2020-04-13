## TODO interface name may vary - discover/check it?
## Could check for an interface connected to 192.168.100.1,
## but unlikely to be specific enough.
class ccs_network (String $daq_interface) {

  ## Note: asked not to modify DAQ network interfaces.
  $interface = "DISABLED-${daq_interface}"

  $file = '30-ethtool'

  file { "/etc/NetworkManager/dispatcher.d/${file}":
    ensure => file,
    content => epp("${title}/${file}", {'interface' => $interface}),
    mode => '0755',
  }

}
