#!/bin/sh
# /usr/local/ports/ld-preload-open_build.sh 0755 root:root
set -e; export LC_ALL

DESCRIPTION="map files or directories to another location, for use with LD_PRELOAD"
HOMEPAGE="https://github.com/fritzw/ld-preload-open"
LICENSE="MIT"
PN="ld-preload-open"
PV="20220614"
SRC_URI="https://github.com/fritzw/${PN}/archive/master.tar.gz -> ${PN}-${PV}.tar.gz"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}-master"  # src_dir and build_dir
ZCOMP="gunzip"
PF="${SRC_URI##*[/[:space:]]}"
IFS=$(printf '\n\t%1s') LC_ALL="C"

# Install build tools dependencies
apk add build-base musl-fts-dev

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/

cd ${work_dir}/ || exit
[ -f "${PF}" ] || wget -O "${PF}" "${SRC_URI%%[[:space:]]*}"

[ -d "${build_dir}" ] || {
${ZCOMP} -dc "${PF}" | tar -C "${work_dir}/" -xkf -
printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${work_dir}/ -xkf -"
}
cd ${build_dir}/ || exit

sed -e 's/-Wall//' -i Makefile
sed \
  -e 's/struct \([a-zA-Z_0-9]*\)64/struct \1/g' \
  -e 's/.*\(define DISABLE_FTW\)/#\1/g' \
  -e '1i#define __OPEN_NEEDS_MODE(oflag) (((oflag) & O_CREAT) != 0 || ((oflag) & O_TMPFILE) == O_TMPFILE)' \
  -i path-mapping.c

gcc -O2 -std=c99 -Wall -DQUIET -shared -fPIC path-mapping.c -o path-mapping-quiet.so -ldl ||
{ echo "Failed make build" >&2; exit 1; }

rm -v -r /usr/local/lib/path-mapping-quiet.so || true  # remove old install

strip --verbose --strip-all path-mapping-quiet.so
cp -v path-mapping-quiet.so /usr/local/lib/ || { echo "make install... error" >&2; exit 1; }
