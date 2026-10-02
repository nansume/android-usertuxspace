#!/bin/sh
# /usr/local/ports/fiche_build.sh 0755 root:root
# shellgen-ports.git/net-misc/fiche/build-script.sh
set -e; export LC_ALL

DESCRIPTION="Command line pastebin server"
HOMEPAGE="https://github.com/solusipse/fiche"
LICENSE="MIT"
PN="fiche"
PV="20181220"
SRC_URI="https://github.com/solusipse/${PN}/archive/master.tar.gz -> ${PN}-${PV}.tar.gz"
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

[ -e ".patched" ] ||
for F in "/usr/local/ports/patches/${PN}-${PV}/"*".diff"; do
  [ -e "${F}" ] && { patch -p1 -E < "${F}"; echo "patch -p1 -E < ${F}"; >.patched; }
done

make -j "$(nproc)" LDFLAGS="-Wl,-z,stack-size=262144" || { echo "Failed make build" >&2; exit 1; }
rm -v -r /usr/local/bin/${PN} || true  # remove old install

strip --verbose --strip-all "${PN}"
cp -v -l "${PN}" /usr/local/bin/ || { echo "make install... error" >&2; exit 1; }
