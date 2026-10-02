#!/bin/sh
# ----------------------------------------
# File: /usr/local/ports/tcpd_build.sh 0755 root:root
# ----------------------------------------
# shellgen-ports.git/sys-apps/tcp-wrappers/build-script.sh
set -e; export LC_ALL

IFS="$(printf '\n\t')"; IFS=${IFS%?}
#PKG_DIR="/usr/local/pkgs"
LC_ALL="C"
PKGNAME="tcp_wrappers"
PN="tcp-wrappers"
#XPN=${PN}
PV="7.6"
SYMVER="0.${PV}"
DESCRIPTION="TCP Wrappers"
HOMEPAGE="http://ftp.porcupine.org/pub/security"
SRC_URI="
  http://ftp.porcupine.org/pub/security/${PKGNAME}_${PV}.tar.gz
  http://deb.debian.org/debian/pool/main/t/${PN}/${PN}_${PV}.q-32.debian.tar.xz
  https://dev.gentoo.org/~soap/distfiles/${PN}-${PV}.31-patches.tar.xz
"
LICENSE="tcp_wrappers_license"
work_dir="/var/tmp/${PN}"
src_dir="${work_dir}/${PKGNAME}_${PV}"
build_dir=${src_dir}

# Install build tools dependencies
apk add build-base
#apk add binutils gcc patch make  # TIP!: it remove, wrong

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/
#[ -d "${src_dir}" ] || mkdir -m 0755 ${src_dir}/
[ -d "/usr/local/sbin" ] || mkdir -m 0755 /usr/local/sbin/  # TIP!: it remove
[ -d "/usr/local/lib" ] || mkdir -m 0755 /usr/local/lib/  # TIP!: it remove

cd ${work_dir}/ || exit

for i in ${SRC_URI}; do
  i=${i%%#*}
  i="${i%${i##*[![:space:]]}}"
  PF=${i##*[/[:space:]]}
  [ -n "${i}" ] && { [ -f "${PF}" ] || busybox wget -O "${PF}" "${i#${i%%[![:space:]]*}}"; }
done

[ -d "${build_dir}" ] || {
for F in *.tar.gz *.tar.xz; do
  ZCOMP="unxz"; case ${F} in *.gz) ZCOMP="gunzip";; esac
  ${ZCOMP} -dc ${F} | tar -C "${work_dir}/" -xkf -
  printf %s\\n "${ZCOMP} -dc ${F} | tar -C ${work_dir}/ -xkf -"
done
}
cd ${build_dir}/ || exit

[ -e ".patched" ] || {
for F in $(sed -e 's:^:../debian/patches/:' ../debian/patches/series || exit) ../gentoo-patches/*.patch; do
  [ -e "${F}" ] && { patch -p1 -E < "${F}"; printf %s\\n "patch -p1 -E < ${F}";}
done; >.patched
}
OPTS_IPV6="-DINET6=1 -Dss_family=__ss_family -Dss_len=__ss_len"

make \
  prefix= LIBDIR="/usr/local/lib" REAL_DAEMON_DIR="/usr/local/sbin" \
  TLI= VSYSLOG= PARANOID= BUGS= AUTH= DOT= HOSTNAME= NETGROUP= LIBS= \
  AUX_OBJ="weak_symbols.o" \
  COPTS="-O2 -DHAVE_WEAKSYMS -DHAVE_STRERROR -DSYS_ERRLIST_DEFINED ${OPTS_IPV6}" \
  musl || { echo "Failed make build" >&2; exit 1; }

rm -v /usr/local/sbin/tcpd* /usr/local/lib/libwrap.so.${SYMVER} || true  # remove old install

strip --verbose --strip-all tcpd tcpdmatch shared/libwrap.so.${SYMVER}

cp -l tcpd tcpdmatch "/usr/local/sbin/"
cp -l shared/libwrap.so.${SYMVER} "/usr/local/lib/"
cp -l tcpd.h "/usr/include/" || true

ln -s libwrap.so.${SYMVER} /usr/local/lib/libwrap.so.0 || true
ln -s libwrap.so.0 /usr/local/lib/libwrap.so || true