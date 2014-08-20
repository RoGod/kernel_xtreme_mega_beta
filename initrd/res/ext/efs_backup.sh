#!/sbin/busybox sh
#
# EFS backup
export PATH="/res/ext:${PATH}"
DATA_PATH="/data/media/0/Xtreme-Mega-Data"
DATA="/storage/sdcard1/Xtreme-Mega-Data"
BUSY="/sbin/busybox"
BLOCK="/dev/block/mmcblk0p3"

if [ ! -f $DATA_PATH/efs.tar.gz ]; then
	$BUSY mkdir $DATA_PATH
	$BUSY chmod -R 777 $DATA_PATH
	$BUSY cd /efs
	$BUSY tar zcvf $DATA_PATH/efs.tar.gz .
	$BUSY cat $BLOCK > $DATA_PATH/efs.img
	$BUSY cd $DATA_PATH
	$BUSY gzip -q efs.img
	$BUSY chmod -R 777 $DATA_PATH
	$BUSY chmod -R 777 $DATA_PATH/*
	$BUSY mkdir $DATA
	$BUSY cp -r $DATA_PATH/* $DATA
	$BUSY chmod -R 777 $DATA
	$BUSY chmod -R 777 $DATA/*
fi;

# Thanks to ::rogod::
