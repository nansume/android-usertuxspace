#!/bin/sh

LOGFILE="/var/log/sshtunnel.log"
SSH_USER="nobody"     # user for remote ssh server
SSH_SERVER="0.0.0.0"  # ip/domain address a remote ssh server

export EDITOR="nano"

#exec >> ${LOGFILE} 2>&1

if ! ps | head | grep -q -- ' -p 2222 '; then
  dropbear -r /etc/dropbear/dropbear_ed25519_host_key -p 2222 -s -T 10
  upnpc -e SSH-SERVER -a @ 2022 22 TCP 0 >/dev/null 2>&1
  upnpc -e SSH-SERVER -a @ 2022 2022 TCP 0 >/dev/null 2>&1
  upnpc -e SSH-SERVER -a @ 2222 2222 TCP 0 >/dev/null 2>&1
  upnpc -e VNC-SERVER -a @ 5900 5900 TCP 0 >/dev/null 2>&1
fi

if ! ps | head | grep -q -- 'dbclient'; then
  dbclient \
    -i /root/.ssh/id_dropbear_tunnel \
    -R 2323:127.0.0.1:2323 \
    -f -N -p 22 \
    ${SSH_USER}@${SSH_SERVER} >> ${LOGFILE} 2>&1 &
fi

pgrep "inetd" || inetd "/etc/inetd.conf"

echo "load profile... ok" >&0
