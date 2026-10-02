#!/bin/sh

export RSYNC_SSL_CA_CERT="/etc/ssl/certs/ca-certificates.crt"  # rsync over stunnel
export USER_NET=$(uidgetuser '2000')
export UPNP_URI=$(upnpc-uri 2>/dev/null)

#[ -n ${UPNP_URI-}" ] || unset UPNP_URI

#set -- $(pgrep -n -f "^dropbear .* -p 2022 "); shift 3
#set -- $(pgrep -x "dropbear") ''; shift 2
#
#for PID in ${@}; do
#  [ -n "${PID}" ] && kill -9 ${PID}
#done

#( set -- "$(pgrep -n -x '.*/proot')" $(pgrep -x '.*/proot'); PID=${3:+$1}; [ -n "${PID}" ] && kill -9 ${PID} )

[ -x "/usr/local/lib/ld-preload-socket.so" ] && {
  export LD_PRELOAD_SOCKET_INET_PORT_MAP="53:2053"
  export LD_PRELOAD="/usr/local/lib/ld-preload-socket.so"
}
