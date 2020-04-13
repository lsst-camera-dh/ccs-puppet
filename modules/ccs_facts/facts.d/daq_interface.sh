#!/bin/sh

## TODO interface name may vary - discover/check it?
## Could check for an interface connected to 192.168.100.1,
## but unlikely to be specific enough.

iface=p3p1

## Sometimes p3p1 is renamed to lsst-daq.
/usr/sbin/ip link show lsst-daq >& /dev/null && iface=lsst-daq

echo "daq_interface: $iface"
