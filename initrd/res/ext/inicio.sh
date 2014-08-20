#!/sbin/busybox sh
#
# scrip

# set busybox location
export PATH="/res/ext:${PATH}"
BUSY="/sbin/busybox"

$BUSY mount -o remount,rw,nosuid,nodev /cache;
$BUSY mount -o remount,rw,nosuid,nodev /data;
$BUSY mount -o remount,rw /;
$BUSY mount -o remount,rw /lib/modules;

# cleaning
$BUSY rm -rf /cache/lost+found/* 2> /dev/null;
$BUSY rm -rf /data/lost+found/* 2> /dev/null;
$BUSY rm -rf /data/tombstones/* 2> /dev/null;
$BUSY rm -rf /data/anr/* 2> /dev/null;

# critical Permissions fix
$BUSY chown -R root:system /sys/devices/system/cpu/;
$BUSY chown -R system:system /data/anr;
$BUSY chown -R root:radio /data/property/;
$BUSY chmod -R 777 /tmp/;
$BUSY chmod -R 6755 /sbin/ext/;
$BUSY chmod -R 0777 /dev/cpuctl/;
$BUSY chmod -R 0777 /data/system/inputmethod/;
$BUSY chmod -R 0777 /sys/devices/system/cpu/;
$BUSY chmod -R 0777 /data/anr/;
$BUSY chmod 0744 /proc/cmdline;
$BUSY chmod -R 0770 /data/property/;
$BUSY chmod -R 0400 /data/tombstones;

# fix owners on critical folders
$BUSY chown -R root:root /tmp;
$BUSY chown -R root:root /res;
$BUSY chown -R root:root /sbin;
$BUSY chown -R root:root /lib;

$BUSY sync;



