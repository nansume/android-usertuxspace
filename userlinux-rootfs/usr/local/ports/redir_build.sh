#!/bin/sh
# /usr/local/ports/redir_build.sh 0755 root:root
# shellgen-ports.git/net-misc/redir/build-script.sh
set -e; export LC_ALL

DESCRIPTION="TCP port redirector"
HOMEPAGE="https://github.com/troglobit/redir"
LICENSE="GPL-2"
PN="redir"
PV="3.3"
SRC_URI="https://github.com/troglobit/${PN}/releases/download/v${PV}/${PN}-${PV}.tar.xz"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}-${PV}"  # src_dir and build_dir
ZCOMP="unxz"
PF="${SRC_URI##*[/[:space:]]}"
IFS=$(printf '\n\t%1s') LC_ALL="C"

# Install build tools dependencies
apk add build-base

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/

cd ${work_dir}/ || exit
[ -f "${PF}" ] || wget -O "${PF}" "${SRC_URI}"

[ -d "${build_dir}" ] || {
${ZCOMP} -dc "${PF}" | tar -C "${work_dir}/" -xkf -
printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${work_dir}/ -xkf -"
}
cd ${build_dir}/ || exit

[ -e "Makefile" ] ||
./configure --disable-compat --enable-shaping --enable-ftp --without-libwrap ||
{ echo "configure... error" >&2; exit 1; }

make -j "$(nproc)" CFLAGS="-O2" || { echo "Failed make build" >&2; exit 1; }
rm -v -r /usr/local/bin/redir || true  # remove old install

strip --verbose --strip-all "${PN}"
cp -v -l "${PN}" /usr/local/bin/ || { echo "make install... error" >&2; exit 1; }