#!/bin/sh
### BEGIN INIT INFO
# Provides:             boot-fsck
# Required-Start:       
# Required-Stop:      
# Default-Start:
# Default-Stop:
# Short-Description:	runs recommended fsck(8) at boot
### END INIT INFO

case "$1" in
        start)
		test -x /etc/init.d/mmc-slowdown && /etc/init.d/mmc-slowdown start
                fsck -a -p -t ext2
                fsck -a -p -t ext4
                ;;
        stop)
                ;;
        *)
                echo "Usage $0 (start|stop)" >&2
                exit 1
                ;;
esac

: exit 0
