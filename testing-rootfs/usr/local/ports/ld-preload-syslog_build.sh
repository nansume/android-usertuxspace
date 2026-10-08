#!/bin/sh
# /usr/local/ports/ld-preload-syslog_build.sh 0755 root:root
set -e; export LC_ALL

DESCRIPTION="LD_PRELOAD to intercept syslog"
HOMEPAGE="http://musl.libc.org"
LICENSE="MIT LGPL-2 GPL-2"
PN="ld-preload-syslog"
SPN="musl"
PV="1.2.5"
SRC_URI="http://musl.libc.org/releases/${SPN}-${PV}.tar.gz"
work_dir="/var/tmp/${SPN}"
build_dir="${work_dir}/${SPN}-${PV}/src/misc"  # src_dir and build_dir
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

sed -e 's|"/dev/log"|"/tmp/syslog"|;s|"/dev/console"|"/dev/null"|' -i syslog.c

gcc -I../include -I../internal -I../../arch/$(arch) -O2 -Wall -shared -fPIC syslog.c -o syslog.so -ldl ||
{ echo "Failed make build" >&2; exit 1; }

rm -v -r /usr/local/lib/syslog.so || true  # remove old install

strip --verbose --strip-all syslog.so
cp -v syslog.so /usr/local/lib/ || { echo "make install... error" >&2; exit 1; }
