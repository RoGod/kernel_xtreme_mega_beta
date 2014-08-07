#!/sbin/busybox sh
#
#
# Script inicio soporte init.d

log_file="/data/media/0/Xtreme-Mega-Data/init.d.log"

if [ -e $log_file ] ; then
   rm $log_file;
fi;

SYSTEM_DEVICE="/dev/block/mmcblk0p9"
BUSY="/system/xbin/busybox"
BUSY="/sbin/busybox"
LOGW="/system/bin/logwrapper"
INITD="/system/etc/init.d"

# Permisos Init.d

echo `date +"%F %R:%S : Init.d script execution support enabled."` >>$log_file

if [ ! -d "/system/etc/init.d" ]; then
$BUSY mount -o remount,rw -t ext4 $SYSTEM_DEVICE /system
  $BUSY mkdir /system/etc/init.d
  $BUSY chown -R 0 $INITD
  $BUSY chgrp -R 2000 $INITD
  $BUSY chmod -R 755 $INITD
  $BUSY chmod 777 $INITD/*
$BUSY mount -o remount,ro -t ext4 $SYSTEM_DEVICE /system
fi;

echo `date +"%F %R:%S : Init.d scripts permissions reset to 0:2000 755."` >>$log_file

ls -al $INITD >>$log_file

echo `date +"%F %R:%S : Init.d starting execution..."` >>$log_file

# Soporte Init.d

export PATH="/sbin:/system/sbin:/system/bin:/system/xbin"

if [ -d /system/etc/init.d ]; then
  $BUSY run-parts $INITD
  $LOGW run-parts $INITD
fi;

echo `date +"%F %R:%S : Init.d execution finished."` >>$log_file
