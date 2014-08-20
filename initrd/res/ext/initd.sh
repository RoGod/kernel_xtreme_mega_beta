#!/sbin/busybox sh
#
#
# Script inicio soporte init.d

export PATH="/sbin:/system/sbin:/system/bin:/system/xbin"
SYSTEM_DEVICE="/dev/block/mmcblk0p9"
BUSY="/sbin/busybox"
LOGW="/system/bin/logwrapper"
INITD="/system/etc/init.d"
RUN="/system/xbin/run-parts"

# soporte Init.d
if [ -d "$INITD" ]; then
	$BUSY mount -o remount,rw -t ext4 $SYSTEM_DEVICE /system
	$BUSY mkdir $INITD
	$BUSY rm /data/ROGOD_INITD
		if [ ! -f $INITD/01ROGOD_INITD ]; then
				$BUSY touch $INITD/01ROGOD_INITD
			{
				echo "#!/system/bin/sh"
				echo "#"
				echo "# soporte $INITD"
				echo
				echo "$BUSY sync"
				echo "$BUSY touch /data/ROGOD_INITD"
				echo
				echo "		{"
				echo "			echo Soporte init.d con éxito."
				echo "			echo"
				echo "			echo Usted podrá ejecutar script en init.d"
				echo "			echo y mejorar su experiencia con android"
				echo "			echo"
				echo "			echo Thanks to ::rogod::"
				echo "			echo"
				echo "		} >> /data/ROGOD_INITD"
				echo
				echo "$BUSY chmod -R 666 /data/ROGOD_INITD"
				echo "$BUSY sync"
				echo
				echo "# Thanks to ::rogod::"
			} >> "$INITD/01ROGOD_INITD"
		fi;
			
	$BUSY chown -R root:root $INITD
	$BUSY chown -R 0 $INITD
	$BUSY chgrp -R 2000 $INITD
	$BUSY chmod -R 755 $INITD
	$BUSY chmod -R 777 $INITD/*
	$BUSY $RUN $INITD
	$LOGW $BUSY $RUN $INITD
	$BUSY mount -o remount,ro -t ext4 $SYSTEM_DEVICE /system
  
fi;
	$BUSY sync
	
	# Thanks to ::rogod::
