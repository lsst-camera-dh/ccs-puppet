#!/bin/sh

## The "primary" network interface, eg em1 or p4p1.
eth0=$(nmcli -g ip4.address,general.device dev show 2> /dev/null | \
    gawk '/^(134|140|139)/ {getline; print $0; exit}')

[ "$eth0" ] || {
    echo "WARNING: unable to determine primary network interface" >&2
    exit 1
}

echo "main_interface=$eth0"

exit 0
