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

if [ -e ramdisk.cpio ]; then
        rm ramdisk.cpio
fi;

if [ -e ramdisk.cpio.gz ]; then
        rm ramdisk.cpio.gz
fi;

if [ -e initrd.cpio ]; then
        rm initrd.cpio
fi;

if [ -e initrd.cpio.gz ]; then
        rm initrd.cpio.gz
fi;

make distclean
make clean
make clean && make mrproper
rm Module.symvers

echo "#################### Preparando Entorno ####################"

if [ "${1}" != "" ]; then
	export KERNELDIR=`readlink -f ${1}`;
else
	export KERNELDIR=`readlink -f .`;
fi;

export RAMFS_SOURCE=`readlink -f $KERNELDIR/initrd`
export USE_SEC_FIPS_MODE=true
export ARCH=arm
NR_CPUS=$(expr `grep processor /proc/cpuinfo | wc -l` + 1);

if [ "${1}" != "" ]; then
  export KERNELDIR=`readlink -f ${1}`
fi;

TOOLCHAIN="/home/rogod/android-ndk-r8e/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-"
MODULES="/home/rogod/Kernel/modules"
RAMFS_TMP="/home/rogod/Kernel/tmp/ramfs-source-sgs3"
export KERNEL_VERSION="Xtreme-Mega"
export REVISION="BETA"
export KBUILD_BUILD_VERSION="6"

echo "#################### Verificando rutas ####################"

echo "kerneldir = $KERNELDIR"
echo "ramfs_source = $RAMFS_SOURCE"
echo "ramfs_tmp = $RAMFS_TMP"

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

find . -type f -name '*.h' -exec chmod 644 {} \;
find . -type f -name '*.c' -exec chmod 644 {} \;
find . -type f -name '*.py' -exec chmod 755 {} \;
find . -type f -name '*.sh' -exec chmod 755 {} \;
find . -type f -name '*.pl' -exec chmod 755 {} \;

echo "#################### Eliminando build anterior ####################"

make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j${NR_CPUS} mrproper || exit 1

rm -rf $KERNELDIR/arch/arm/boot/zImage

echo "#################### Make defconfig ####################"

make ARCH=arm CROSS_COMPILE=$TOOLCHAIN rogod_defconfig

nice -n 10 make -j${NR_CPUS} ARCH=arm CROSS_COMPILE=$TOOLCHAIN || exit 1

echo "#################### Update Ramdisk ####################"

rm -f $KERNELDIR/Xtreme-Mega/tar/$KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar
rm -f $KERNELDIR/Xtreme-Mega/tar/boot.img
rm -f $KERNELDIR/Xtreme-Mega/zip/$KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.zip
rm -f $KERNELDIR/Xtreme-Mega/zip/boot.img

rm -rf $RAMFS_TMP
rm -rf $RAMFS_TMP.cpio
rm -rf $RAMFS_TMP.cpio.gz
rm -rf $KERNELDIR/*.cpio
rm -rf $KERNELDIR/*.cpio.gz
cd $RAMFS_SOURCE
cp -ax $RAMFS_SOURCE $RAMFS_TMP
cp $MODULES/* $RAMFS_TMP/lib/modules
find $RAMFS_TMP -name .git -exec rm -rf {} \;
find $RAMFS_TMP -name EMPTY_DIRECTORY -exec rm -rf {} \;
find $RAMFS_TMP -name .EMPTY_DIRECTORY -exec rm -rf {} \;
rm -rf $RAMFS_TMP/tmp/*
rm -rf $RAMFS_TMP/.hg
chmod 644 $RAMFS_TMP/lib/modules/*
echo "#################### Build Ramdisk ####################"

cd $RAMFS_TMP
find . | fakeroot cpio -o -H newc > $RAMFS_TMP.cpio 2>/dev/null
ls -lh $RAMFS_TMP.cpio
gzip -9 -f $RAMFS_TMP.cpio

echo "#################### Compilar Kernel ####################"

cd $KERNELDIR

nice -n 10 make -j${NR_CPUS} ARCH=arm CROSS_COMPILE=$TOOLCHAIN zImage || exit 1

echo "#################### Generar boot.img ####################"

./mkbootimg --kernel $KERNELDIR/arch/arm/boot/zImage --ramdisk $RAMFS_TMP.cpio.gz --board smdk4x12 --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 -o $KERNELDIR/boot.img

echo "#################### Preparando flasheables ####################"

cp boot.img $KERNELDIR/Xtreme-Mega/zip
cp boot.img $KERNELDIR/Xtreme-Mega/tar

cd $KERNELDIR
cd Xtreme-Mega/zip
zip -9 -r $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.zip *
cd ..
cd tar
tar cf $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar boot.img && ls -lh $KERNEL_VERSION-$REVISION$KBUILD_BUILD_VERSION.tar

echo "#################### Eliminando restos ####################"
find -name '*.ko' -exec rm -rf {} \;
rm -rf $KERNELDIR/Xtreme-Mega/zip/boot.img
rm -rf $KERNELDIR/Xtreme-Mega/tar/boot.img
rm -f $KERNELDIR/arch/arm/boot/*.dtb
rm -f $KERNELDIR/arch/arm/boot/*.cmd
rm -rf $KERNELDIR/arch/arm/boot/Image
rm -rf $KERNELDIR/arch/arm/boot/zImage
rm $KERNELDIR/boot.img
rm $KERNELDIR/zImage
rm -rf $RAMFS_TMP/*
rm /home/rogod/Kernel/tmp/ramfs-source-sgs3.cpio.gz

echo "#################### Terminado ####################"
