#!/bin/sh
# /usr/local/ports/syslog-redir_build.sh 0755 root:root
set -e; export LC_ALL

DESCRIPTION="LD_PRELOAD to intercept syslog"
PN="syslog-redir"
PV="20261007"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}-${PV}"  # src_dir and build_dir
IFS=$(printf '\n\t%1s') LC_ALL="C"

# Install build tools dependencies
apk add build-base

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/

[ -d "${build_dir}" ] || {
  cp -v -r /usr/local/ports/sources/${PN}-${PV} -t "${work_dir}/"
}
cd ${build_dir}/ || exit

gcc -O2 -Wall -shared -fPIC syslog-redir.c -o syslog-redir.so -ldl ||
{ echo "Failed make build" >&2; exit 1; }

rm -v -r /usr/local/lib/syslog-redir.so || true  # remove old install

strip --verbose --strip-all syslog-redir.so
cp -v syslog-redir.so /usr/local/lib/ || { echo "make install... error" >&2; exit 1; }
