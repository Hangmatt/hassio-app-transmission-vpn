#!/bin/sh
natpmpc -a 1 0 udp 60 -g 10.2.0.1 >/dev/null 2>&1
PORT=$(natpmpc -a 1 0 tcp 60 -g 10.2.0.1 | awk '/Mapped public port/ {print $4}')

if [ -n "$PORT" ]; then
  echo "$(date): Active ProtonVPN Port is $PORT"
  transmission-remote -n 'Hassio:Hassio' -p "$PORT"
else
  echo "$(date): Failed to get port from 10.2.0.1"
fi

