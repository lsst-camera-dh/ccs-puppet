#!/bin/sh

for rpm in gdm; do
    if rpm -q --quiet $rpm; then
        installed=true
    else
        installed=false
    fi
    printf "rpm_${rpm}=$installed\n" # string not boolean
done

exit 0
