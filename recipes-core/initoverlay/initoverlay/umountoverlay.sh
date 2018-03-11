#!/bin/sh
### BEGIN INIT INFO
# Provides:          umountoverlay
# Required-Start:
# Required-Stop:     umountnfs
# Should-Stop:
# Default-Start:
# Default-Stop:      0 6
# Short-Description: Unmount all overlay filesystems
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin

echo "Unmounting overlay filesystems..."

test -f /etc/fstab && (

#
#	Read through fstab line by line and umount overlay file systems
#
egrep '^(unionfs|overlay)' /etc/fstab | while read device mountpt fstype options
do
	if test "$fstype" = unionfs -o "$fstype" = "overlayfs" -o "$fstype" = "overlay"
	then
		umount -f $mountpt
	fi
done
)

: exit 0
