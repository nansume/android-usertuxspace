#!/bin/sh

# http://data.gpo.zugaina.org/guru/net-misc/yacy/yacy-1.930.202405130205.ebuild
# http://data.gpo.zugaina.org/guru/net-misc/yacy/files/yacy.rc
# https://kb.shells.com/tutorials/Alpine_Linux_Latest/Yacy/

# TIP!: nowork: #apk add openjdk25-jdk
# TIP!: Prep: apk add openjdk11-jdk

IFS="$(printf '%1s\n\t')"
PN="yacy"
YACY_USER="yacy"              #$(head -n1 /etc/sysconfig/yacy/user)
YACY_HOME="/usr/share/${PN}"  #$(head -n1 /etc/sysconfig/yacy/home)
YACY_USERID="8090"            #$(head -n1 /etc/sysconfig/yacy/userid)
TARFILE="yacy_v1.941_202603291103_f0464e7fb.tar.gz"
workdir="/var/tmp/src"
S="${workdir}/${PN}"
hash="65bda0eae8d12f41f9cc3558e888db0162d13ea7cfc9e91e3a5c0dff4ef333e7"

mkdir -p "${workdir}/" "${S}/" "${YACY_HOME}/" "${YACY_HOME}/DATA"
cd "${workdir}/"
wget "https://download.yacy.net/${TARFILE}"

echo "hash: '${hash}'"
echo "hash: '$(sha256sum ${TARFILE})'"

gunzip -dc yacy_*.tar.gz | tar -C "${workdir}/" -xkf -

# remove win-only stuff
find "${S}" -name "*.bat" -exec rm '{}' \;
# remove init-scripts
rm "${S}"/*.sh
# remove sources
rm -r "${S}/source"
rm "${S}/build.properties" "${S}/build.xml"

cp -r "${S}"/* "${YACY_HOME}"
echo "Install YACY... ok"

# TIP!: it check a the user is exist, not group!
if ! groups ${YACY_USER} >/dev/null 2>&1; then
  addgroup -g ${YACY_USERID} ${YACY_USER}
  adduser -u ${YACY_USERID} -D -G ${YACY_USER} -h ${YACY_HOME} -s "/bin/sh" ${YACY_USER}

  printf %s\\n "adduser ${YACY_USER}"
fi

mkdir "/var/log/yacy/"
chown ${YACY_USER}:${YACY_USER} "/var/log/yacy"

ln -s "${YACY_HOME}/DATA" /var/lib/yacy

echo "yacy.logging will write logfiles into /var/lib/yacy/LOG"
echo "To setup YaCy, open http://localhost:8090 in your browser."
