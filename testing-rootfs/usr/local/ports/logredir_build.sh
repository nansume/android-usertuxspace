#!/bin/sh
# /usr/local/ports/logredir_build.sh 0755 root:root
set -e; export LC_ALL

# BUG: gnusism from glibc - no build

DESCRIPTION="LD_PRELOAD mechanism to intercept syslog API call"
HOMEPAGE="https://github.com/dpocock/logredir"
LICENSE="GPL-2+"  # based on syslog.c from the glibc project.
PN="logredir"
PV="20120810"
SRC_URI="https://github.com/dpocock/${PN}/archive/master.tar.gz -> ${PN}-${PV}.tar.gz"
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

sed -e 's|^#include <bits/libc-lock.h>$||' -i logredir.c

gcc -O2 -std=c99 -Wall -shared -fPIC logredir.c -o logredir.so -ldl ||
{ echo "Failed make build" >&2; exit 1; }

rm -v -r /usr/local/lib/logredir.so || true  # remove old install

strip --verbose --strip-all logredir.so
cp -v logredir.so /usr/local/lib/ || { echo "make install... error" >&2; exit 1; }
