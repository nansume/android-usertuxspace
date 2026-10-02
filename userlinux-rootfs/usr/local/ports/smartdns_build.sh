#!/bin/sh
# /usr/local/ports/smartdns_build.sh 0755 root:root
# http://data.gpo.zugaina.org/gentoo/net-dns/smartdns/smartdns-48.4.ebuild
set -e; export LC_ALL

DESCRIPTION="A local DNS server returns the fastest access results"
HOMEPAGE="https://github.com/pymumu/smartdns"
LICENSE="GPL-3"
PN="smartdns"
PV="48.4"
SRC_URI="https://github.com/pymumu/smartdns/archive/Release${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}-Release${PV}"  # src_dir and build_dir
ZCOMP="gunzip"
PF="${SRC_URI##*[/[:space:]]}"
IFS=$(printf '\n\t%1s') LC_ALL="C"

# Install build tools dependencies
apk add build-base zlib openssl

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/

cd ${work_dir}/ || exit
[ -f "${PF}" ] || wget -O "${PF}" "${SRC_URI%%[[:space:]]*}"

[ -d "${build_dir}" ] || {
${ZCOMP} -dc "${PF}" | tar -C "${work_dir}/" -xkf -
printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${work_dir}/ -xkf -"
}
cd ${build_dir}/ || exit

make -j "$(nproc)" CFLAGS="-O2" SYSCONFDIR="/etc" WITH_ZLIB="0" || { echo "Failed make build" >&2; exit 1; }
rm -v -r /usr/local/sbin/smartdns || true  # remove old install

strip --verbose --strip-all src/${PN}
cp -v src/${PN} /usr/local/sbin/ || { echo "make install... error" >&2; exit 1; }