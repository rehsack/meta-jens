#!/bin/sh
### BEGIN INIT INFO
# Provides:             daemontools
# Required-Start:       
# Required-Stop:      
# Default-Start:
# Default-Stop:
# Short-Description:  runs svscanboot &
### END INIT INFO

case "$1" in
	start)
		/etc/init.d/svscanboot &
		;;
	stop)
		logger -s "Stopping services"
		svc -d /etc/daemontools/service/*
		sleep 2
		svstat /etc/daemontools/service/* | logger -s
		svc -dk /etc/daemontools/service/*
		sleep 2
		svstat /etc/daemontools/service/* | logger -s

		killall supervise
		killall readproctitle
		killall svscan

		;;
	*)
		echo "Usage $0 (start|stop)" >&2
		exit 1
		;;
esac

: exit 0
