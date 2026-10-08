# UserTux for Android

UserTux scipts and configs for Android.

---

## Requirements

- Android 5.0+ (unrooted)
- UserLAnd
-  Alpine Linux

---

## Install in the UserLAnd chroot

```
% cd /tmp/
% wget "https://github.com/nansume/android-usertuxspace/raw/master/scripts/install_usertux.sh"
% /tmp/install_usertux.sh
```

---

## Access from your PC

```
dbclient -i ${HOME}/.ssh/id_dropbear -K 1 -p 2022 root@192.168.0.100
```

---

### License

This work is multi-licensed under either GPLv3 or MIT license or UnLicense.
