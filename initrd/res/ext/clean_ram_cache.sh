#!/sbin/busybox sh
#

BUSY="/sbin/busybox"
BUSY="/system/xbin/busybox"

$BUSY mount -o remount,rw /;
echo "START" > /data/ram_clean;
chmod 777 /data/ram_clean;

(
	MEM_FREE=`free | grep Mem | awk '{ print $4 }'`;
	CALC_MEM=`echo $(($MEM_FREE/1024))M`;
	echo "FREE BEFORE $CALC_MEM" > /data/ram_clean;
	echo "PLEASE WAIT WORKING"  >> /data/ram_clean;

	sync;
	sysctl -w vm.drop_caches=3 > /dev/null 2>&1;
	MEM_FREE_AFTER=`free | grep Mem | awk '{ print $4 }'`;
	CALC_MEM_AFTER=`echo $(($MEM_FREE_AFTER/1024))M`;
	echo "FREE AFTER $CALC_MEM_AFTER" >> /data/ram_clean;
	echo "All-Done" >> /data/ram_clean;
)&

while [ ! `cat /data/ram_clean | grep "All-Done" | wc -l` == "1" ]; do
	sleep 2;
done;
RAM_LOG=`cat /data/ram_clean`;
echo "$RAM_LOG";

# clean cache

$BUSY sync
$BUSY rm -f /cache/*.apk
$BUSY rm -f /cache/*.tmp
$BUSY rm -f /data/dalvik-cache/*.apk
$BUSY rm -f /data/dalvik-cache/*.tmp
$BUSY rm -f /data/data/com.google.android.gms/files/flog
$BUSY sync
$BUSY sleep 1