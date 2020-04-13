#!/bin/bash

## FIXME facter mountpoints./home tells us this.
for m in / /data /home /opt /scratch /tmp /var; do

    if [ "$m" == "/" ]; then
	mount=root
    else
	mount=${m#/}
	mount=${mount//\//_}
    fi

    if [ -d "$m" ] && grep -q "$m " /etc/mtab; then
	mounted=true
	inodes=$(df --output=itotal $m | tail -n 1)
	printf "inodes_${mount}=$inodes\n"
    else
	mounted=false
    fi
    printf "mounted_${mount}=$mounted\n" # string not boolean

done


exit 0
