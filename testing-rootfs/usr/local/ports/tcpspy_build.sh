#!/bin/sh
# /usr/local/ports/tcpspy_build.sh 0755 root:root
# shellgen-ports.git/net-analyzer/tcpspy/build-script.sh
set -e

DESCRIPTION="Incoming and Outgoing TCP/IP connections logger (libc: dietlibc or musl)"
HOMEPAGE="https://salsa.debian.org/debian/tcpspy"
LICENSE="BSD 3-Clause"
IFS=$(printf '\n\t%1s')
LC_ALL="C"
PN="tcpspy"
PV="1.7d15"
SRC_URI="https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/${PN}/1.7d-15/${PN}_1.7d.orig.tar.gz
https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/${PN}/1.7d-15/${PN}_1.7d-15.debian.tar.xz"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}-1.7d.orig"

# Install build tools dependencies
apk add build-base linux-headers bison flex

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/
[ -d "${build_dir}" ] || mkdir -m 0755 ${build_dir}/

cd ${work_dir}/ || exit
for i in ${SRC_URI}; do
  i=${i%%#*}
  i="${i%${i##*[![:space:]]}}"
  [ -n "${i}" ] && wget "${i#${i%%[![:space:]]*}}"
done
for F in *.tar.gz *.tar.xz; do
  ZCOMP="unxz"; case ${F} in *.gz) ZCOMP="gunzip";; esac
  ${ZCOMP} -dc ${F} | tar -C "${work_dir}/" -xkf -
  printf %s\\n "${ZCOMP} -dc ${F} | tar -C ${work_dir}/ -xkf -"
done

cd ${build_dir}/ || exit

for F in ../debian/patches/*.patch; do
  [ -e "${F}" ] && { patch -p1 -E < "${F}"; printf %s\\n "patch -p1 -E < ${F}"; }
done
patch -p1 -E < /usr/local/ports/patches/${PN}-${PV}/tcpspy-fix-u_int-musl.diff

make -j "$(nproc)" CFLAGS="-O2 -std=c89 -D_GNU_SOURCE" || { echo "Failed make build"; exit 1; }

rm -v /usr/local/sbin/tcpspy || true  # remove old install

strip --verbose --strip-all "${PN}"
cp -l tcpspy "/usr/local/sbin/"