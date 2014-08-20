#!/sbin/busybox sh
#

export PATH="/res/ext:${PATH}"
BUSY="/sbin/busybox"

	if [ "$(pgrep -f "database_optimizing.sh" |  wc -l)" -le "5" ]; then

		for i in `$BUSY find /data -iname "*.db"`; do
			/sbin/sqlite3 $i 'VACUUM;';
			/sbin/sqlite3 $i 'REINDEX;';
		done;

		for i in `$BUSY find /sdcard -iname "*.db"`; do
			/sbin/sqlite3 $i 'VACUUM;';
			/sbin/sqlite3 $i 'REINDEX;';
		done;
	fi;
