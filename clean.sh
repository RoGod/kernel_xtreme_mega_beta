#!/bin/bash

TOOLCHAIN="/home/rogod/android-ndk-r8e/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-"
DIR="/home/rogod/android/Kernel"
NR_CPUS=$(expr `grep processor /proc/cpuinfo | wc -l` + 1);

echo "#################### Eliminando Restos ####################"

if [ -e boot.img ]; then
	rm boot.img
fi

make distclean
make clean
make clean && make mrproper
rm Module.symvers


# clean ccache
read -t 5 -p "clean ccache, 5sec timeout (y/n)?"
if [ "$REPLY" == "y" ]; then
	ccache -C
fi

echo "ramfs_tmp = $RAMFS_TMP"

echo "#################### Eliminando build anterior ####################"

echo "Cleaning latest build"
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j${NR_CPUS} mrproper
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j${NR_CPUS} clean

find -name '*.ko' -exec rm -rf {} \;
rm -rf $DIR/arch/arm/boot/zImage
rm -f $DIR/arch/arm/boot/*.dtb
rm -f $DIR/arch/arm/boot/*.cmd
rm -rf $DIR/arch/arm/boot/Image
rm $DIR/boot.img
rm $DIR/zImage
