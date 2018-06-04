#/bin/bash

DATE=`date +%Y-%m-%d_%H:%M`
#IMGNAME=rpi-android-$DATE.img
IMGNAME=rpi.img
IMGSIZE=4  #SD image size in MB

partisions(){
	echo "Creating partitions..."
	dd if=/dev/zero of=$IMGNAME bs=1024k count=$(($IMGSIZE*1024))
	sync
	sudo kpartx -a $IMGNAME
	LOOPDEV=$(basename $(sudo losetup -jrpi.img | awk -F: '{print $1}'|head -n1))
	sync
	(
	echo o
	echo n
	echo p
	echo 1
	echo
	echo +512M
	echo n
	echo p
	echo 2
	echo
	echo +512M
	echo n
	echo p
	echo 3
	echo
	echo +512M
	echo n
	echo p
	echo
	echo
	echo t
	echo 1
	echo c
	echo a
	echo 1
	echo w) | sudo fdisk /dev/${LOOPDEV}
	sudo kpartx -d $IMGNAME
	sudo kpartx -a $IMGNAME
	sleep 5
	sudo mkfs.fat -F 32 /dev/mapper/${LOOPDEV}p1
	sudo mkfs.ext4 /dev/mapper/${LOOPDEV}p4
}

boot(){
	sudo kpartx -a $IMGNAME
	sync
	sleep 5
	mkdir -p p1
	sudo mount /dev/mapper/${LOOPDEV}p1 p1
	sudo scp -r ${ANDROID_BUILD_TOP}/device/brcm/rpi3/boot/* p1/
	sudo scp -r ${ANDROID_BUILD_TOP}/kernel/rpi/arch/arm/boot/zImage p1/
	sudo scp -r ${ANDROID_BUILD_TOP}/kernel/rpi/arch/arm/boot/dts/bcm2710-rpi-3-b.dtb p1/
	sudo mkdir -p p1/overlays
	sudo scp -r ${ANDROID_BUILD_TOP}/kernel/rpi/arch/arm/boot/dts/overlays/vc4-kms-v3d.dtbo p1/overlays/vc4-kms-v3d.dtbo
	sudo scp -r ${ANDROID_BUILD_TOP}/kernel/rpi/arch/arm/boot/dts/overlays/sdio.dtbo p1/overlays/sdio.dtbo
	sudo echo 'dtoverlay=sdio,poll_once=off' >> p1/config.txt
	sudo scp -r ${ANDROID_BUILD_TOP}/out/target/product/rpi3/ramdisk.img  p1/
	sudo umount /dev/mapper/${LOOPDEV}p1
}


system(){
	sudo kpartx -a $IMGNAME
	sudo dd if=${ANDROID_BUILD_TOP}/out/target/product/rpi3/system.img of=/dev/mapper/${LOOPDEV}p2 bs=1M
	sync
}


#[ -z "$ANDROID_BUILD_TOP" ] && echo "Android build not defined, please go to android build dir\
# and use:\n\tsource build/envsetup.sh\n\tlunch rpi3-eng\n" && exit	

if [ -z $1 ] ; then
        partisions && boot && system 
else
        for f in $@; do echo $f:; $f; done
fi

sudo kpartx -d $IMGNAME
sudo rm -rf p1 p2 p3 p4
