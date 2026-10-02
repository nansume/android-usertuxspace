#!/bin/sh
# /usr/local/ports/dnsmasq0_build.sh 0755 root:root
set -e; export LC_ALL

DESCRIPTION="Small forwarding DNS server (old version)"
HOMEPAGE="https://thekelleys.org.uk/dnsmasq/doc.html"
LICENSE="|| ( GPL-2 GPL-3 )"
PN="dnsmasq"
PV="2.27"
SRC_URI="https://thekelleys.org.uk/dnsmasq/archive/${PN}-${PV}.tar.gz"
work_dir="/var/tmp/${PN}"
build_dir="${work_dir}/${PN}-${PV}"  # src_dir and build_dir
ZCOMP="gunzip"
PF="${SRC_URI##*[/[:space:]]}"
IFS=$(printf '\n\t%1s') LC_ALL="C"

# Install build tools dependencies
apk add build-base linux-headers

[ -d "${work_dir}" ] || mkdir -m 0755 ${work_dir}/

cd ${work_dir}/ || exit
[ -f "${PF}" ] || wget -O "${PF}" "${SRC_URI}"

[ -d "${build_dir}" ] || {
${ZCOMP} -dc "${PF}" | tar -C "${work_dir}/" -xkf -
printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${work_dir}/ -xkf -"
}
cd ${build_dir}/ || exit

[ -e ".patched" ] ||
for F in "/usr/local/ports/patches/${PN}-${PV}/"*".diff"; do
  [ -e "${F}" ] && { patch -p1 -E < "${F}"; echo "patch -p1 -E < ${F}"; >.patched; }
done

COPTS="-DNO_DBUS -DNO_UBUS -DNO_IDN -DNO_LIBIDN2 -DNO_IPSET -DNO_NFTSET -DNO_CONNTRACK"
COPTS="${COPTS} -DNO_LUASCRIPT -DNO_SCRIPT -DNO_DNSSEC -DNO_AUTH -DNO_GMP -DNO_LOOP -DNO_DHCP -DNO_DHCP6"
COPTS="${COPTS} -DNO_INOTIFY -DNO_ID -DNO_DHCP -DNO_DUMPFILE -DNO_TFTP -DNO_LINUX_NETWORK"

make -j "$(nproc)" COPTS="-O2 ${COPTS}" || { echo "Failed make build"; exit 1; }

rm -v /usr/local/sbin/dnsmasq || true  # remove old install

strip --verbose --strip-all "src/${PN}"
cp -v src/dnsmasq "/usr/local/sbin/"