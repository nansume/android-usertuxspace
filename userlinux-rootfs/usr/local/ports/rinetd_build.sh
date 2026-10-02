#!/bin/sh
# /usr/local/ports/rinetd_build.sh 0755 root:root
# shellgen-ports.git/net-misc/rinetd/build-script.sh
set -e; export LC_ALL

DESCRIPTION="redirects TCP connections from one IP address and port to another"
HOMEPAGE="https://github.com/samhocevar/rinetd"
LICENSE="GPL-2+ GPL-2"
PN="rinetd"
PV="0.73"
SRC_URI="https://github.com/samhocevar/rinetd/releases/download/v${PV}/${PN}-${PV}.tar.bz2"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}-${PV}"  # src_dir and build_dir
ZCOMP="bunzip2"
PF="${SRC_URI##*[/[:space:]]}"
IFS=$(printf '\n\t%1s') LC_ALL="C"

# Install build tools dependencies
apk add build-base

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/

cd ${work_dir}/ || exit
[ -f "${PF}" ] || wget -O "${PF}" "${SRC_URI%%[[:space:]]*}"

[ -d "${build_dir}" ] || {
${ZCOMP} -dc "${PF}" | tar -C "${work_dir}/" -xkf -
printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${work_dir}/ -xkf -"
}
cd ${build_dir}/ || exit
[ -e "Makefile" ] || ./configure --sysconfdir=/etc || { echo "configure... error" >&2; exit 1; }

make -j "$(nproc)" CFLAGS="-O2" || { echo "Failed make build" >&2; exit 1; }
rm -v -r /usr/local/sbin/${PN} || true  # remove old install

strip --verbose --strip-all "${PN}"
cp -v -l "${PN}" /usr/local/sbin/ || { echo "make install... error" >&2; exit 1; }
