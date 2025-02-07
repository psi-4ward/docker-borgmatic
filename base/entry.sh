#!/bin/sh

# Import your cron file
/usr/bin/crontab /etc/borgmatic.d/crontab.txt

#Variables
borgver=$(borg --version)
borgmaticver=$(borgmatic --version)
apprisever=$(apprise --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

#Software versions
echo borgmatic $borgmaticver
echo $borgver
echo apprise $apprisever

# broadcast signals to crond and borgmatic
TO_KILL=${TO_KILL:-"borgmatic crond"}
graceful_shutdown() {
  for P in $TO_KILL ; do
    PIDS=$(pgrep $P)
    if [ -n "$PIDS" ] ; then
      killall -$1 $P
      wait $PIDS
    fi 
  done
}

for s in SIGHUP SIGINT SIGTERM; do
  trap "graceful_shutdown $s" $s
done

# Start cron
/usr/sbin/crond -f -L /dev/stdout &

wait
