#!/bin/sh
# /usr/local/ports/ld-preload-socket_build.sh 0755 root:root
set -e; export LC_ALL

DESCRIPTION="Use LD_PRELOAD to redirect socket ports or unix domain socket paths"
HOMEPAGE="https://github.com/iqe/ld-preload-socket"
LICENSE="MIT"
PN="ld-preload-socket"
PV="20200929"
SRC_URI="https://github.com/iqe/${PN}/archive/master.tar.gz -> ${PN}-${PV}.tar.gz"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}-master"  # src_dir and build_dir
ZCOMP="gunzip"
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

sed -e '/^#include <netinet\/in.h>$/a #include <string.h>' -i ld-preload-socket.c

[ -e ".patched" ] ||
for F in "/usr/local/ports/patches/${PN}-${PV}/"*".diff"; do
  [ -e "${F}" ] && { patch -p1 -E < "${F}"; echo "patch -p1 -E < ${F}"; >.patched; }
done

gcc -O2 -std=c99 -Wall -shared -fPIC ld-preload-socket.c -o ld-preload-socket.so -ldl ||
{ echo "Failed make build" >&2; exit 1; }

rm -v -r /usr/local/lib/ld-preload-socket.so || true  # remove old install

strip --verbose --strip-all ld-preload-socket.so
cp -v ld-preload-socket.so /usr/local/lib/ || { echo "make install... error" >&2; exit 1; }
