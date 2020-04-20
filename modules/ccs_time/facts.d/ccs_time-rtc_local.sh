#!/bin/sh

rtc_local='false'

timedatectl | grep -q 'RTC in local TZ: yes' && rtc_local=true

echo "rtc_local=$rtc_local"
