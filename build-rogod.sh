#!/bin/bash
#
clear
echo "#################### Eliminando Restos ####################"

if [ -e boot.img ]; then
        rm boot.img
fi;

if [ -e compile.log ]; then
        rm compile.log
fi;

if [ -e initrd.cpio ]; then
        rm initrd.cpio
fi;

if [ -e initrd.cpio.gz ]; then
        rm initrd.cpio.gz
fi;

make distclean
make clean && make mrproper
rm Module.symvers

echo "#################### Preparando Entorno ####################"

if [ "${1}" != "" ]; then
	export KERNELDIR=`readlink -f ${1}`
else
	export KERNELDIR=`readlink -f .`
fi;

export RAMFS_SOURCE=`readlink -f $KERNELDIR/initrd`
export XTREME=`readlink -f $KERNELDIR/Xtreme-Mega`
export USE_SEC_FIPS_MODE=true
export ARCH=arm
NR_CPUS=$(expr `grep processor /proc/cpuinfo | wc -l` + 1)

BUSYBOX="/home/rogod/Kernel/busybox"
MODULES="/home/rogod/Kernel/modules"
INITRAMFS_TMP="/home/rogod/Kernel/tmp/ramfs-source-sgs3"
TOOLCHAIN="/home/rogod/android-ndk-r8e/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-"
export KERNEL_VERSION="Xtreme-Mega"
export REVISION="V"
export KBUILD_BUILD_VERSION="1"

echo "#################### Verificando rutas ####################"

echo "toolchain = ${TOOLCHAIN}"
echo "kerneldir = ${KERNELDIR}"
echo "ramfs_source = ${RAMFS_SOURCE}"
echo "ramfs_tmp = ${RAMFS_TMP}"
echo "nr_cpus = ${NR_CPUS}"

echo "#################### Aplicando Permisos correctos ####################"

chmod 644 $RAMFS_SOURCE/*.rc
chmod 750 $RAMFS_SOURCE/init*
chmod 640 $RAMFS_SOURCE/fstab*
chmod 644 $RAMFS_SOURCE/default.prop
chmod 771 $RAMFS_SOURCE/data
chmod 755 $RAMFS_SOURCE/dev
chmod 755 $RAMFS_SOURCE/lib
chmod 755 $RAMFS_SOURCE/lib/modules
chmod 755 $RAMFS_SOURCE/proc
chmod 750 $RAMFS_SOURCE/sbin
chmod 750 $RAMFS_SOURCE/sbin/*
chmod 755 $RAMFS_SOURCE/sys
chmod 755 $RAMFS_SOURCE/system
chmod 775 $RAMFS_SOURCE/res
chmod 755 $RAMFS_SOURCE/res/ext
chmod 644 $RAMFS_SOURCE/res/ext/*

find . -type f -name '*.h' -exec chmod 644 {} \;
find . -type f -name '*.c' -exec chmod 644 {} \;
find . -type f -name '*.py' -exec chmod 755 {} \;
find . -type f -name '*.sh' -exec chmod 755 {} \;
find . -type f -name '*.pl' -exec chmod 755 {} \;

echo "#################### Eliminando build anterior ####################"

make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j${NR_CPUS} mrproper
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j${NR_CPUS} clean

echo "#################### compilar kernel ####################"

make ARCH=arm CROSS_COMPILE=$TOOLCHAIN rogod_defconfig

nice -n 10 make -j${NR_CPUS} ARCH=arm CROSS_COMPILE=$TOOLCHAIN || exit 1

nice -n 10 make -j${NR_CPUS} ARCH=arm CROSS_COMPILE=$TOOLCHAIN zImage || exit 1

nice -n 10 make -j${NR_CPUS} ARCH=arm CROSS_COMPILE=$TOOLCHAIN modules || exit 1

echo "#################### Update initrd ####################"

if [ -d $INITRAMFS_TMP ]; then
	rm -rf $INITRAMFS_TMP
	rm -rf $INITRAMFS_TMPcpio
	rm -rf $INITRAMFS_TMPcpio.gz
else
	mkdir $INITRAMFS_TMP
	chown root:root $INITRAMFS_TMP
	chmod 777 $INITRAMFS_TMP
fi;

rm -rf $KERNELDIR/*.cpio
rm -rf $KERNELDIR/*.cpio.gz
cp -ax $RAMFS_SOURCE $INITRAMFS_TMP
mkdir -p $INITRAMFS_TMP/lib/modules

find $INITRAMFS_TMP -name .git -exec rm -rf {} \;

# remove empty directory placeholders from ramfs_tmp
find $INITRAMFS_TMP -name EMPTY_DIRECTORY -exec rm -rf {} \;
find $INITRAMFS_TMP -name .EMPTY_DIRECTORY -exec rm -rf {} \;
rm -rf $INITRAMFS_TMP/tmp/*
rm -rf $INITRAMFS_TMP/.hg

# copiando mudules personales
cp $MODULES/* $INITRAMFS_TMP/lib/modules

# copy modules into tmp-initramfs
#find . -type f -iname "*.ko" | while read line; do
#	${TOOLCHAIN}strip --strip-unneeded "$line"
#	cp "$line" "$INITRAMFS_TMP/lib/modules/;"
#done

chmod 755 $INITRAMFS_TMP/lib/modules/*

# copiando binario busybox completo
#cp $BUSYBOX/* $INITRAMFS_TMP/sbin
#chmod 750 $INITRAMFS_TMP/sbin/*

echo "#################### Build initrd ####################"

cd $INITRAMFS_TMP
find . | fakeroot cpio -o -H newc > $INITRAMFS_TMP.cpio 2>/dev/null
ls -lh $INITRAMFS_TMP.cpio
gzip -9 -f $INITRAMFS_TMP.cpio

echo "#################### Generar boot.img ####################"

cd $KERNELDIR
./mkbootimg --kernel $KERNELDIR/arch/arm/boot/zImage --ramdisk $INITRAMFS_TMP.cpio.gz --board smdk4x12 --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 -o $KERNELDIR/boot.img

echo "#################### Preparando flasheables ####################"

# eliminando flasheables antiguos
rm -f $XTREME/tar/*.tar
rm -f $XTREME/md5/*.md5
rm -f $XTREME/zip/*.zip

# copiando boot.img a ruta de flasheables
cp boot.img $XTREME/zip
cp boot.img $XTREME/tar
cp boot.img $XTREME/md5

# comprimiendo en formato zip
cd $XTREME/zip
zip -ry -9 "$KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.zip" . -x "*.zip"

# comprimiendo en formato tar
cd ../tar
tar cf $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar boot.img && ls -lh $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar

# comprimiendo en formato tar.md5
cd ../md5
tar -H ustar -c boot.img > $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar
md5sum -t $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar >> $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar
mv $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar.md5
cd ../..

echo "#################### Eliminando restos ####################"

# remove all old modules before compile
find "$KERNELDIR" -type f -iname "*.ko" | while read line; do
	rm -f "$line"
done

# remover all old compilaciones
rm -f $XTREME/zip/boot.img
rm -f $XTREME/tar/boot.img
rm -f $XTREME/md5/boot.img
rm -f $KERNELDIR/arch/arm/boot/*.dtb
rm -f $KERNELDIR/arch/arm/boot/*.cmd
rm -rf $KERNELDIR/arch/arm/boot/Image
rm -rf $KERNELDIR/arch/arm/boot/zImage
rm -f $KERNELDIR/boot.img
rm -rf $INITRAMFS_TMP/*
cd $INITRAMFS_TMP
cd ..
rm ramfs-source-sgs3.cpio.gz
rm /home/rogod/Kernel/tmp/ramfs-source-sgs3.cpio.gz

echo "#################### Terminado ####################"