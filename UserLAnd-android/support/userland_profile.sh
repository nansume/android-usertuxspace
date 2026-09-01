#!/bin/sh
unset LD_PRELOAD
unset LD_LIBRARY_PATH
export LIBGL_ALWAYS_SOFTWARE=1
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

export USER_NET=$(uidgetuser '2000')
export UPNP_URI=$(upnpc-uri)

#[ -n ${UPNP_URI-}" ] || unset UPNP_URI

[ -e "/etc/profile.d/zzzzzzzzzzzzzzzz.sh" ] && rm /etc/profile.d/zzzzzzzzzzzzzzzz.sh
