#!/bin/sh

if [ ! -f /support/.ssh_setup_complete ]; then
  rm -rf /etc/dropbear
  mkdir /etc/dropbear
  dropbearkey -t dss -s 1024 -f /etc/dropbear/dropbear_dss_host_key
  dropbearkey -t rsa -s 2048 -f /etc/dropbear/dropbear_rsa_host_key
  dropbearkey -t ecdsa -s 521 -f /etc/dropbear/dropbear_ecdsa_host_key
  > /support/.ssh_setup_complete
fi

dropbear -E -r /etc/dropbear/dropbear_ed25519_host_key -p 2022 -s -T 10

export USER_NET=$(uidgetuser '2000')

wait-procfs-net  # FIX: waiting for default route init in procfs [or <sleep 3> sec]

# FIX: it no tmpfs
for X in /tmp/rc-local.lock /support/proot-[0-9]*[0-9]-*; do
  if [ -d "${X}" ]; then
    rmdir -- "${X}"
  elif [ -e "${X}" ]; then
    rm -- "${X}"
  fi
done

export UPNP_URI=$(upnpc-uri)
upnpc -u "${UPNP_URI}" -e SSH-SERVER -a $(netdev-ip) 2022 22 TCP 0 >/dev/null 2>&1
upnpc -u "${UPNP_URI}" -e SSH-SERVER -a $(netdev-ip) 2022 2022 TCP 0 >/dev/null 2>&1

/etc/rc.local >/dev/null 2>&1
