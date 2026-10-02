#!/bin/sh
# /usr/local/ports/jabberd2_build.sh 0755 root:root
# shellgen-ports.git/net-im/jabberd2/build-script.sh
set -e; export LC_ALL

DESCRIPTION="Open Source Jabber Server"
HOMEPAGE="http://jabberd2.org"
LICENSE="GPL-2"
PN="jabberd2"
PV="2.7.0"
SRC_URI="https://github.com/jabberd2/${PN}/releases/download/jabberd-${PV}/jabberd-${PV}.tar.xz"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN%?}-${PV}"  # src_dir and build_dir
ZCOMP="unxz"
PF="${SRC_URI##*[/[:space:]]}"
IFS=$(printf '\n\t%1s') LC_ALL="C"

# Install build tools dependencies
apk add build-base expat-dev db-dev libidn-dev udns-dev libgsasl-dev openssl-dev

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/

cd ${work_dir}/ || exit
[ -f "${PF}" ] || wget -O "${PF}" "${SRC_URI}"

[ -d "${build_dir}" ] || {
${ZCOMP} -dc "${PF}" | tar -C "${work_dir}/" -xkf -
printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${work_dir}/ -xkf -"
}
cd ${build_dir}/ || exit

# Fix some default directory locations
sed -i \
  -e 's,@localstatedir@/@package@/pid/,/var/run/@package@/,g' \
  -e 's,@localstatedir@/@package@/run/pbx,/var/run/@package@/pbx,g' \
  -e 's,@localstatedir@/@package@/log/,/var/log/@package@/,g' \
  -e 's,@localstatedir@/lib/jabberd2/fs,@localstatedir@/@package@/fs,g' \
  -e 's,@localstatedir@,/var/spool,g' \
  -e 's,@package@,jabber,g' \
  etc/sm.xml.dist.in \
  etc/router.xml.dist.in \
  etc/c2s.xml.dist.in \
  etc/s2s.xml.dist.in \
  || { echo "fixing default directory locations failed!" >&2; }

# If the package wasn't merged with sqlite then default to use berkdb
sed -i \
  -e 's,<\(module\|driver\)>sqlite<\/\1>,<\1>db</\1>,g' \
  etc/c2s.xml.dist.in etc/sm.xml.dist.in || { echo "setting berkdb as default failed!" >&2; }

# avoid file collision with x11-misc/screen-message wrt #453994
sed -i \
  -e 's/@jabberd_router_bin@/jabberd2-router/' \
  -e 's/@jabberd_c2s_bin@/jabberd2-c2s/' \
  -e 's/@jabberd_s2s_bin@/jabberd2-s2s/' \
  -e 's/@jabberd_sm_bin@/jabberd2-sm/' \
  etc/jabberd*.in || { echo "fixing file collisions failed!" >&2; }

# rename pid files wrt #241472
sed -i \
  -e '/pidfile/s/${id}\.pid/jabberd2-c2s\.pid/' \
  etc/c2s.xml.dist.in || { echo "sed failed!" >&2; }
sed -i \
  -e '/pidfile/s/${id}\.pid/jabberd2-router\.pid/' \
  etc/router.xml.dist.in || { echo "sed failed!" >&2; }
sed -i \
  -e '/pidfile/s/${id}\.pid/jabberd2-s2s\.pid/' \
  etc/s2s.xml.dist.in || { echo "sed failed!" >&2; }
sed -i \
  -e '/pidfile/s/${id}\.pid/jabberd2-sm\.pid/' \
  etc/sm.xml.dist.in || { echo "sed failed!" >&2; }

[ -e "Makefile" ] ||
./configure \
  --prefix="/usr" \
  --exec-prefix="" \
  --bindir="/usr/local/bin" \
  --sysconfdir="/etc/jabber" \
  --libdir="/usr/local/lib" \
  --datadir="/usr/share" \
  --mandir="/usr/share/man" \
  --disable-pipe \
  --disable-anon \
  --enable-fs \
  --enable-ssl \
  --disable-mysql \
  --disable-pgsql \
  --disable-sqlite \
  --enable-db \
  --disable-ldap \
  --disable-pam \
  --disable-websocket \
  --enable-experimental \
  --disable-tests \
  --with-extra-include-path="/usr/include" \
  --with-zlib \
  --enable-shared \
  --disable-static \
  || { echo "configure... error" >&2; exit 1; }

make -j "$(nproc)" CC="cc" CFLAGS="-O2" || { echo "Failed make build" >&2; exit 1; }

rm -v -r /usr/local/bin/jabberd* /usr/local/lib/jabberd/ || true  # remove old install

make install-strip || { echo "make install... error" >&2; exit 1; }

mkdir -m 0755 /var/spool/jabber/ /var/spool/jabber/fs/ /var/spool/jabber/db/ ||:

# avoid file collision with x11-misc/screen-message wrt #453994
for i in router sm c2s s2s ; do
  echo "renaming /usr/local/bin/${i} to /usr/local/bin/jabberd2-${i}"
  mv /usr/local/bin/${i} /usr/local/bin/jabberd2-${i} ||:
done

rm -v -- /etc/jabber/*.dist /etc/jabber/templates/*.dist ||:
rm -v -- /usr/local/lib/jabberd/*.la ||:
rm -v -- /usr/etc/init/jabberd-*.conf ||:
rm -v -- /usr/lib/systemd/system/jabberd*.service ||:
