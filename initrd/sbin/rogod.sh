#!/sbin/busybox sh
#
# Script inicio rogod.sh

BUSY="/sbin/busybox"
BUSY="/system/xbin/busybox"
SYSTEM_DEVICE="/dev/block/mmcblk0p9"

$BUSY mount -o remount,rw -t ext4 $SYSTEM_DEVICE /system
$BUSY mount -t rootfs -o remount,rw rootfs

##### script #####

$BUSY sh /res/ext/efs_backup.sh
$BUSY sh /res/ext/initd.sh
$BUSY sh /res/ext/clean_ram_cache.sh

$BUSY mount -t rootfs -o remount,ro rootfs
$BUSY mount -o remount,ro -t ext4 $SYSTEM_DEVICE /system