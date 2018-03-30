#/bin/bash

# This script will checkout qcaqcl driver and openwrt repos.
# Then builds firmware for 8devices BLUE Bean and/or RED Bean testing
# This script only for testing purpolse not all features tested!

DRIVER_ROOT_DIR="$PWD"

#Checkouts driver repo, if repo already exists pulls new changes from remote and rebase local changes on top
checkout_driver(){
	ret=1

	git status > /dev/null 2>&1 && ON_REPO=1 || ON_REPO=0

	if [ $ON_REPO -ne 0 ] ; then
		DRIVER_ROOT_DIR="`git rev-parse --show-toplevel`" &&\
			echo git pull --rebase && ret=0 ||\
			echo pulling changes failed!!
	else
		DRIVER_ROOT_DIR="$PWD/qcacld-2.0" && git clone \
		https://github.com/8devices/qcacld-2.0 -b caf-wlan/LNX.LEH.4.2.2.2 \
		&& ret=0
		cd $DRIVER_ROOT_DIR
	fi

	return $ret
}

#Checkouts openwrt repo for linux-kernel-4.4 support
checkout_openwrt(){
	OPENWRT_ROOT_DIR="$DRIVER_ROOT_DIR/../openwrt"
	DIR="$PWD"
	ret=1

	if [ -d "$OPENWRT_ROOT_DIR" ] ; then
		echo openwrt dir already exists
	else
		cd $DRIVER_ROOT_DIR/../ &&\
			git clone https://github.com/openwrt/openwrt.git &&\
			cd openwrt && git checkout 993989880a && override_openwrt_files && ret=0
	fi

	cd $DIR
	return $ret
}

#Overrides openwrt cfg files and applies patches
override_openwrt_files(){
	OPENWRT_ROOT_DIR="$DRIVER_ROOT_DIR/../openwrt"
	OPENWRT_FILES="$DRIVER_ROOT_DIR/openwrt_files"
	DIR="$PWD"
	ret=1

	cp $OPENWRT_FILES/image-config $OPENWRT_ROOT_DIR/target/linux/brcm2708/image/config.txt &&\
	cp $OPENWRT_FILES/kernel-config-4.4 $OPENWRT_ROOT_DIR/target/linux/brcm2708/bcm2710/config-4.4 &&\
	cp $OPENWRT_FILES/menu-config $OPENWRT_ROOT_DIR/.config &&\
	cd $OPENWRT_ROOT_DIR && patch -p1 < $OPENWRT_FILES/fix-image-build.patch
	ret=0

	cd $DIR
	return $ret
}

build_openwrt(){
	OPENWRT_ROOT_DIR="$DRIVER_ROOT_DIR/../openwrt"
	DIR="$PWD"
	ret=1

	rm $DRIVER_ROOT_DIR/openwrt-out -rf
	cd $OPENWRT_ROOT_DIR && make clean && make -j4 && mkdir $DRIVER_ROOT_DIR/openwrt-out &&\
		ln -s $PWD/bin/brcm2708/*img $DRIVER_ROOT_DIR/openwrt-out && \
		ln -s $PWD/build_dir/target-arm_cortex-a53+neon-vfpv4_musl-1.1.14_eabi/linux-brcm2708_bcm2710/linux-4.4.4/net/wireless/cfg80211.ko \
		 $DRIVER_ROOT_DIR/openwrt-out/ && ret=0


	cd $DIR
	return $ret
}

build_driver(){
	DIR="$PWD"
	ret=1

	cd $DRIVER_ROOT_DIR && make clean && make -j4 && ret=0

	cd $DIR
	return $ret
}

#Comment any of the steps if you want to skip

set -e

checkout_driver
checkout_openwrt
build_openwrt
build_driver
