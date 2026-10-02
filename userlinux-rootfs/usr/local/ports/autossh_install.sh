#!/bin/sh
# TIP!: In package manager (Alpine Linux), wrong deps for autossh, hence we install that so.
IFS=$(printf '\n\t%1s')
PN="autossh"
workdir="/var/tmp/packages/${PN}"

##########################################
mkdir -pm 0755 /var/tmp/packages/autossh/

apk fetch autossh
apk extract --allow-untrusted --destination /var/tmp/packages/autossh /var/tmp/packages/autossh-*.apk

mv -v /var/tmp/packages/autossh/usr/bin/autossh /bin/

echo "Install autossh... ok"