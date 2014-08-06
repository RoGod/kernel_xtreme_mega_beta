#!/system/bin/sh

# EFS backup
DATA_PATH="/data/media/0/efs"
BUSY="/sbin/busybox"
BUSY="/system/xbin/busybox"
BLOCK="/dev/block/mmcblk0p3"
EXT="/storage/extSdCard"

if [ ! -f $DATA_PATH/efs.tar.gz ];
then
$BUSY mkdir $DATA_PATH
$BUSY chmod -R 777 $DATA_PATH
cd /efs
$BUSY tar zcvf $DATA_PATH/efs.tar.gz .
$BUSY cat $BLOCK > $DATA_PATH/efs.img
cd $DATA_PATH
$BUSY gzip -q efs.img
$BUSY chmod -R 777 $DATA_PATH
$BUSY chmod -R 777 $DATA_PATH/efs*
$BUSY cp -r $DATA_PATH/ $EXT
fi;

# Thanks to ::rogod::