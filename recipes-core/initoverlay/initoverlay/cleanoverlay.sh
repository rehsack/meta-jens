#!/bin/sh
### BEGIN INIT INFO
# Provides:          cleanoverlay
# Required-Start:    $local_fs
# Required-Stop: 
# Default-Start:     S
# Default-Stop:
# Short-Description: Clean overlay filesystems upon request
# Description:
### END INIT INFO

set -x

test -e /etc/default/rcS && . /etc/default/rcS

PATH=/sbin:/bin:/usr/sbin:/usr/bin

test -e /etc/default/cleanoverlay.conf -o -e /etc/cleanoverlay.conf || exit 0

test -e /etc/default/cleanoverlay.conf && . /etc/default/cleanoverlay.conf
test -e /etc/cleanoverlay.conf && . /etc/cleanoverlay.conf

DEF_IFS="$IFS"
for cleanup_spec in ${CLEANUP_SPEC}
do
    test -f "${cleanup_spec}" || continue
    IFS=$'\n'
    path_specs=`<${cleanup_spec}`
    for path_spec in ${path_specs}
    do
	rm -rf "${path_spec}"
    done
    rm -f "${cleanup_spec}"
    IFS="$DEF_IFS"
    sync; sleep 1
done
sync
