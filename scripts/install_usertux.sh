#!/bin/sh

IFS="$(printf '%1s\n\t')"
workdir="/var/tmp/packages"
basedir="${workdir}/master"
rootdir="${basedir}/userlinux-rootfs"

mkdir "${workdir}/"
cd "${workdir}/"

wget "https://github.com/nansume/android-usertuxspace/archive/master.tar.gz"

gunzip -dc master.tar.gz | tar -C "${workdir}/master/" -xkf -

#mkdir /root/.ssh/ /var/www/
mv -v ${rootdir}/* .
mv -v ${basedir}/UserLAnd-android/suppor/* /support/

#${rootdir}/etc/apk/repositories
#${rootdir}/etc/dropbear/dropbear_ed25519_host_key
chmod 600 /etc/dropbear/dropbear_*_host_key

echo "/bin/false" >> /etc/shells

apk update
apk upgrade

#apk update --force-refresh
#apk fix
#apk cache clean

apk add dropbear-dbclient dropbear-ssh dropbear-scp busybox-extras
apk add miniupnpc inetutils-telnet dnsmasq microsocks 3proxy dante
apk add stunnel privoxy privoxy-doc shadowsocks-libev nano nano-syntax mc
apk add tsocks make elinks qalc httplz ttyd openjdk11-jdk
apk add 6tunnel tor i2pd ustream-ssl uhttpd pound uacme inadyn fossil

##########################################
apk fetch autossh
mkdir ./autossh-1.4g-r3
apk extract --allow-untrusted --destination ./autossh-1.4g-r3 ./autossh-1.4g-r3.apk
mv ./autossh-1.4g-r3/usr/bin/autossh /bin/
##########################################

#passwd root

install_yacy

#for nanorc_new in /usr/share/nano/*.nanorc.new; do
#  [ -f "${nanorc_new}" ] || break
#  nanorc=${nanorc%.new}
#  mv -v "${nanorc}" "${nanorc%/*}/.${nanorc##*/}"
#  mv -v "${nanorc_new}" "${nanorc}"
#done

export USER_NET=$(uidgetuser '2000')
export UPNP_URI=$(upnpc-uri)

/etc/rc.local >/dev/null 2>&1

#printf "\e[1;36m${HOSTNAME}\e[m login: "
#read -r WLOGIN
#printf %s "Password: "
#STTY_SAVE=$(stty -g)
#stty -echo
#read -r X
#stty ${STTY_SAVE}

#nc -w 1 -n -z 127.0.0.1 2222 && echo "port: 2222 [open] - ok"

echo "copy your ssh public key: (your-pc)\${HOME}/.ssh/id_dropbear.pub -> (android)/root/.ssh/authorized_keys"
echo "chmod 600 /root/.ssh/authorized_keys"
