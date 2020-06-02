#!/bin/sh

native_gpfs=false

/usr/bin/grep -q "^lsst-fs[123].*gpfs" /etc/fstab && native_gpfs=true

## NB seems impossible to get a boolean rather than a string.
echo "native_gpfs=$native_gpfs"

exit 0
