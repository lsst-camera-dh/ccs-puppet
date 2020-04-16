class ccs_facts {

  ## Interfaces matching given ip pattern.
  $ifaces = $facts['networking']['interfaces'].filter |$eth, $hash| {
    $hash['ip'] and ($hash['ip'] =~ /^(134|140|139)/)
  }
  ## First match.
  $iface = $ifaces.keys()[0]
  $main_interface = pick($iface, 'eth0')

}
