#!/bin/sh
# /usr/local/ports/sslh_build.sh 0755 root:root
# shellgen-ports.git/net-misc/sslh/build-script.sh
set -e; export LC_ALL CPPFLAGS

DESCRIPTION="Port multiplexer - accept both HTTPS and SSH connections on the same port"
HOMEPAGE="https://www.rutschle.net/tech/sslh/README.html"
LICENSE="GPL-2"
PN="sslh"
PV="2.3.1"
SRC_URI="https://github.com/yrutschle/sslh/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}-${PV}"  # src_dir and build_dir
ZCOMP="gunzip"
PF="${SRC_URI##*[/[:space:]]}"
IFS=$(printf '\n\t%1s') LC_ALL="C"

# Install build tools dependencies, (3rd-party manual install dep: tcp-wrappers)
apk add build-base libconfig-dev pcre2-dev libev-dev

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/
#[ -d "${build_dir}" ] || mkdir -m 0755 ${build_dir}/

cd ${work_dir}/ || exit
[ -f "${PF}" ] || wget -O "${PF}" "${SRC_URI%%[[:space:]]*}"

[ -d "${build_dir}" ] || {
${ZCOMP} -dc "${PF}" | tar -C "${work_dir}/" -xkf -
printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${work_dir}/ -xkf -"
}
cd ${build_dir}/ || exit

CPPFLAGS="-D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE"  # add lfs support

[ -e "Makefile" ] ||
./configure --prefix="" --sysconfdir=/etc || { echo "configure... error"; exit 1; }

make -j "$(nproc)" CC="cc" CFLAGS="-O2" \
 USELIBCAP= USELIBEV=yes USELIBWRAP=yes USESYSTEMD= \
 || { echo "Failed make build"; exit 1; }

rm -v /usr/local/sbin/sslh-ev || true  # remove old install

strip --verbose --strip-all "sslh-ev"
cp -l sslh-ev "/usr/local/sbin/"
ln -s sslh-ev "/usr/local/sbin/sslh" || true