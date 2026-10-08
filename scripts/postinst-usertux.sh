#!/bin/sh
# -------------------------------------------------------------------------------------------------
# File: android-usertuxspace.git/scripts/install_usertux.sh
# File: android-usertuxspace.git/scripts/postinst-usertux.sh
# -------------------------------------------------------------------------------------------------
# TIP!: replace: 0.0.0.0  -->  [android-server-ip]
# TIP!: replace: user  -->  [android-server-user]
# -------------------------------------------------------------------------------------------------
# Usage[Android]: run apps, user login
# Usage[Android]: dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key -s 256
# Usage[Android]: killall dropbear, kill apps
# Usage[Android]: run apps
# -------------------------------------------------------------------------------------------------
# Usage[PC]: /bin/dbclient -i ${HOME}/.ssh/id_dropbear -p 2022 user@0.0.0.0
# Usage[SSH]: user login
# Usage[SSH]: cd /usr/local/bin/
# Usage[SSH]: wget https://github.com/nansume/android-usertuxspace/raw/master/scripts/install_usertux.sh
# Usage[SSH]: chmod +x install_usertux.sh
# Usage[SSH]: install_usertux.sh
# -------------------------------------------------------------------------------------------------

echo "SystemUI [Android]: run the UserLAnd apps"
echo "Term [Android]: and user login"
echo "Term [Android]: dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key -s 256"
#echo "SystemUI [Android]: close apps
#echo "SystemUI [Android]: run apps
echo ""

printf "[\e[1;36m0.0.0.0\e[m] remote host: "
read -r HOST
[ -n "${HOST-}" ] || exit

printf "[\e[1;36mroot\e[m] remote auth user: "
read -r AUTH_USER
[ -n "${AUTH_USER-}" ] || exit

AUTH_FILE="${HOME}/.ssh/${AUTH_USER}@android.pwd"

echo "DROPBEAR_PASSWORD=\$(head -n1 ${AUTH_FILE}) \\"
echo "/bin/dbclient -i ${HOME}/.ssh/id_dropbear -p 2022 '${AUTH_USER}@${HOST}'"

DROPBEAR_PASSWORD=$(head -n1 ${AUTH_FILE}) \
/bin/dbclient -i ${HOME}/.ssh/id_dropbear -p 2022 ${AUTH_USER}@${HOST} '

echo "nc -w 6 -l -p 2323 > /root/.ssh/authorized_keys"
nc -w 6 -l -p 2323 > /root/.ssh/authorized_keys &
chmod 600 /root/.ssh/authorized_keys /etc/dropbear/dropbear_*_host_key
'

echo "nc -w 4 ${HOST} 2323 < ${HOME}/.ssh/id_dropbear.pub"
nc -w 4 ${HOST} 2323 < ${HOME}/.ssh/id_dropbear.pub

echo "copy your ssh public key: (your-pc)\${HOME}/.ssh/id_dropbear.pub -> (android)/root/.ssh/authorized_keys"
echo "chmod 600 /root/.ssh/authorized_keys /etc/dropbear/dropbear_\*_host_key"
echo "We make it!... Sucessful"

#exit 0  # testing

########################################################################

dbclient -i ${HOME}/.ssh/id_dropbear -p 2022 root@${HOST} '

IFS=$(printf "\n\t%1s")
workdir="/var/tmp/src"
basedir="${workdir}/android-usertuxspace-master"
rootdir="${basedir}/userlinux-rootfs"

mkdir "${workdir}/"
cd "${workdir}/"

wget "https://github.com/nansume/android-usertuxspace/archive/master.tar.gz"

gunzip -dc master.tar.gz | tar -v -C "${workdir}/" -xkf -

cd /

[ -d "/root/.ssh" ] || mkdir /root/.ssh/
[ -d "/var/www" ] || mkdir /var/www/

cp -v -u -r ${rootdir}/* .
cp -v -u -r ${basedir}/UserLAnd-android/support/* /support/

#${rootdir}/etc/apk/repositories

echo "/bin/false" >> /etc/shells

apk update
apk upgrade

#apk update --force-refresh
apk fix
#apk cache clean

apk add dropbear-dbclient dropbear-ssh dropbear-scp busybox-extras
apk add inetutils-syslogd inetutils-telnet miniupnpc microsocks 3proxy dante
apk add stunnel privoxy privoxy-doc shadowsocks-libev nano nano-syntax mc
apk add tsocks make elinks qalc httplz ttyd openjdk11-jdk dnscrypt-proxy
apk add 6tunnel tor i2pd ustream-ssl uhttpd pound sslh uacme inadyn fossil
apk add socat netcat-openbsd ngircd opentracker openssl git-daemon umurmur
apk add tmux ejabberd pure-ftpd mcabber msmtp exim coturn netatalk ciwiki
apk add nuttcp dircproxy rsync davfs2 tinyproxy
apk add tinc curlftpfs stagit cgit-pink kamailio aria2
#apk add pingu mutt opensmtpd iperf sshfs rtorrent gatling

##########################################

#passwd root

/usr/local/ports/tcpd_build.sh  # we install libs on early stage

for INST_PKG in "/usr/local/ports/"*.sh; do
  case ${INST_PKG} in */tcpd_build.sh) continue;; esac
  ${INST_PKG}
done

#for nanorc_new in /usr/share/nano/*.nanorc.new; do
#  [ -f "${nanorc_new}" ] || break
#  nanorc=${nanorc%.new}
#  mv -v "${nanorc}" "${nanorc%/*}/.${nanorc##*/}"
#  mv -v "${nanorc_new}" "${nanorc}"
#done

########################################################################

printf "(\e[1;36m/etc/motd\e[m) Your Android Device Name: "
read -r MY_DEVICE_NAME
[ -n "${MY_DEVICE_NAME-}" ] && \
sed "s@| My Android Device Name |@| ${MY_DEVICE_NAME} |@" -i /etc/motd

printf "(\e[1;36m/etc/motd\e[m) Your id for manual verify: "
read -r MY_VERIFY_ID
[ -n "${MY_VERIFY_ID-}" ] && \
sed "s@| <your-id-for-manual-review> (@| ${MY_VERIFY_ID} |@" -i /etc/motd

read -r HOSTNAME < /etc/hostname
printf "[\e[1;36m${HOSTNAME}\e[m] Your id for manual verify: "
read -r HOSTNAME
if [ -n "${HOSTNAME-}" ]; then
  echo "${HOSTNAME}" > /etc/hostname
  echo "${HOSTNAME}" > /etc/sysconfig/hostname
fi

# full domain (hostname+domain = host)
#/etc/domain-name.conf
#/etc/sysconfig/domainname

echo "DDNS: Register your own domain here: https://ipv64.net/account - Continue[enter]: "
read
echo "DDNS: IF your registration successful, then config here: /etc/ddns/ipv64net.conf Continue[enter]: "
echo "DDNS: /etc/ddns/ipv64net.conf.sample --> /etc/ddns/ipv64net.conf"
# /etc/ddns/ipv64net.conf.sample

echo "DDNS: Your token here: https://ipv64.net/api"

printf "[\e[1;36myour-token\e[m] Your token: "
read -r TOKEN

if [ -n "${HOSTNAME-}" ] && [ -n "${TOKEN-}"; then
mv -n /etc/ddns/ipv64net.conf.sample /etc/ddns/ipv64net.conf
sed \
  -e "/^password = / s|<token>|${TOKEN}|" \
  -e "/^hostname = / s|<your-hostname>.|${HOSTNAME}.|" \
  -i /etc/ddns/ipv64net.conf

echo "${TOKEN}" > /etc/sysconfig/uacme/ipv64net/token
fi


########################################################################

export USER_NET=$(uidgetuser "2000")
export UPNP_URI=$(upnpc-uri 2>/dev/null)

/etc/rc.local >/dev/null 2>&1

#printf "\e[1;36m${HOSTNAME}\e[m login: "
#read -r WLOGIN
#printf %s "Password: "
#STTY_SAVE=$(stty -g)
#stty -echo
#read -r X
#stty ${STTY_SAVE}

#nc -w 1 -n -z 127.0.0.1 2222 && echo "port: 2222 [open] - ok"
'