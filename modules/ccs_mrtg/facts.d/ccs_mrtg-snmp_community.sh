#!/bin/sh

## Return the community from snmpd.conf, else generate one.

conf=/etc/snmp/snmpd.conf

if [ -r $conf ]; then
    community=$(awk '$1 == "com2sec" && $2 == "local" {print $NF}' $conf)
else
    community=
fi

case $community in
    ""|public)
	## coreutils.
	community=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 22 | head -n 1)
	;;
esac

echo "snmp_community=${community}"

exit 0
