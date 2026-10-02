#!/bin/sh
# /usr/local/ports/http-ping_build.sh 0755 root:root
# shellgen-ports.git/net-analyzer/http-ping/build-script.sh
set -e; export LC_ALL

DESCRIPTION="http_ping - measure HTTP latency"
HOMEPAGE="http://acme.com/software/http_ping/"
LICENSE="2-clause-BSD"
PN="http_ping"
PV="09Mar2016"
SRC_URI="http://acme.com/software/${PN}/${PN}_${PV}.tar.gz"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}"  # src_dir and build_dir
ZCOMP="gunzip"
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

grep -qo '#include <time.h>' http_ping.c || sed '/^#include "port.h"$/a #include <time.h>' -i http_ping.c

make -j "$(nproc)" CFLAGS="-O2" || { echo "Failed make build" >&2; exit 1; }
rm -v -r /usr/local/bin/${PN} || true  # remove old install

strip --verbose --strip-all "${PN}"
cp -v -l "${PN}" /usr/local/bin/ || { echo "make install... error" >&2; exit 1; }
