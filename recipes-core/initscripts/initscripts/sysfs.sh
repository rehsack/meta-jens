#!/bin/sh
### BEGIN INIT INFO
# Provides:          mountvirtfs
# Required-Start:
# Required-Stop:
# Default-Start:     S
# Default-Stop:
# Short-Description: Mount kernel virtual file systems.
# Description:       Mount initial set of virtual filesystems the kernel
#                    provides and that are required by everything.
### END INIT INFO

if [ -e /proc ] && ! [ -e /proc/mounts ]; then
  mount -t proc proc /proc
fi

if [ -e /sys ] && grep -q sysfs /proc/filesystems && ! [ -e /sys/class ]; then
  mount -t sysfs sysfs /sys
fi

if [ -e /sys/kernel/debug ] && grep -q debugfs /proc/filesystems; then
  mount -t debugfs debugfs /sys/kernel/debug
fi

if egrep -q '\<tmpfs\>' /etc/fstab && egrep -q '\<tmpfs\>' /proc/filesystems; then
  for f in `egrep '\<tmpfs\>' /etc/fstab | awk '{print $2}'`; do
    if test 0 -eq `egrep -q "\\<$f\\>" /proc/mounts | wc -l`; then
      mount "$f"
    fi
  done
fi
