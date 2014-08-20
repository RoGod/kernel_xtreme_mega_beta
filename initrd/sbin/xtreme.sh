#!/sbin/busybox sh
#
BUSY="/sbin/busybox"

# Inicio
$BUSY mount -o remount,rw /system
$BUSY mount -t rootfs -o remount,rw rootfs

# Enlace simbólico a xbin
$BUSY sync
if [ ! -f /system/xbin/busybox ]; then
$BUSY ln -s $BUSY /system/xbin/busybox
$BUSY ln -s $BUSY /system/xbin/pkill
fi

# Enlace simbólico a bin
$BUSY sync
if [ ! -f /system/bin/busybox ]; then
$BUSY ln -s $BUSY /system/bin/busybox
$BUSY ln -s $BUSY /system/bin/pkill
fi

# Enlace simbólico a modulos
$BUSY sync
if [ ! -f /system/lib/modules ]; then
$BUSY mkdir -p /system/lib
$BUSY ln -s /lib/modules/ /system/lib
fi

# copiando
$BUSY sync
if [ ! -f /system/xbin/busybox ]; then
$BUSY ln -s $BUSY /system/xbin/busybox
$BUSY ln -s $BUSY /system/xbin/pkill
fi

$BUSY mount -t rootfs -o remount,ro rootfs
$BUSY mount -o remount,ro /system
