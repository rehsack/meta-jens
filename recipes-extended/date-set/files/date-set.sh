#!/bin/sh
### BEGIN INIT INFO
# Provides:		date-set
# Required-Start:
# Required-Stop:
# Default-Start:
# Default-Stop:
# Short-Description:
### END INIT INFO

case "$1" in
        start)
		# Set the system clock from hardware clock
		# If the timestamp is more recent than the current time,
		# use the timestamp instead.
		test -x /etc/init.d/hwclock.sh && /etc/init.d/hwclock.sh start
		if test -e /etc/timestamp
		then
			SYSTEMDATE=`date -u +%4Y%2m%2d%2H%2M%2S`
			read TIMESTAMP < /etc/timestamp
			if [ ${TIMESTAMP} -gt $SYSTEMDATE ]; then
				# format the timestamp as date expects it (2m2d2H2M4Y.2S)
				TS_YR=${TIMESTAMP%??????????}
				TS_SEC=${TIMESTAMP#????????????}
				TS_FIRST12=${TIMESTAMP%??}
				TS_MIDDLE8=${TS_FIRST12#????}
				date -u ${TS_MIDDLE8}${TS_YR}.${TS_SEC}
				test -x /etc/init.d/hwclock.sh && /etc/init.d/hwclock.sh stop
			fi
		fi
                ;;
        stop)
                ;;
        *)
                echo "Usage $0 (start|stop)" >&2
                exit 1
                ;;
esac

: exit 0
