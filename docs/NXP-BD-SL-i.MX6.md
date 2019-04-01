Compile qcacld driver for BD-SL-i.MX6
=====================================

Before compiling qcacld drivers for BD-SL-i.MX6, you have to prepare operating system. Here is official guides and useful links with information:
 - [Development board's vendor wiki](https://boundarydevices.com/wiki/ "Boundary devices wiki")
 - [Buildroot guide for i.MX platforms](https://boundarydevices.com/buildroot-2017-08-imx-platforms/ "Buildroot preparation guide")
 - [Device's homepage](https://boundarydevices.com/product/sabre-lite-imx6-sbc/ "Specification for BD-SL-i.MX6")
 - [Console connection guide](https://boundarydevices.com/just-getting-started/ "How to connect serial console")

# Prepare Buildroot with kernel

1. Download the latest Buildroot tree:

		git clone https://git.busybox.net/buildroot -b 2017.08.x

2. Download Boundary Devices external layer:

		git clone https://github.com/boundarydevices/buildroot-external-boundary -b 2017.08.x

3. Download qcacld driver:

		git clone https://github.com/8devices/qcacld-2.0 -b caf-wlan/LNX.LEH.4.2.2.2

4. Create an output folder for your build:

		make BR2_EXTERNAL=$PWD/buildroot-external-boundary/ -C buildroot/ \
		O=$PWD/output nitrogen6x_qt5_gst1_defconfig
		cd output

5. Build the image:

		make -j${nproc}

	This will take some time.
	After the build, the system should be ready. Check if the image exist with:

		ls -l images/sdcard.img

6. Apply the kernel patch:

		cd build/linux-custom/.
		cp ../../../qcacld-2.0/patches/NXP-i.MX6/0001-Disable-other-voltages-than-1.8V-for-SDIO.patch .
		git apply 0001-Disable-other-voltages-than-1.8V-for-SDIO.patch
		cd ../../

7. Rebuild the image:

		make -j${nproc}

8. Plug the USB stick/SD card to the computer and find out it's name with:

		sudo fdisk -l

9. Write the image to the media:

		sudo dd if=images/sdcard.img of=/dev/sdX bs=1M
		sync

# Build qcacld driver for system

1. Got to qcacld directory:

		cd ../qcacld-2.0/

2. Edit the `Makefile` file accordingly:

		ARCH=arm
		KERNEL_SRC=/PATH/TO/output/build/linux-custom/
		CROSS_COMPILE=/PATH/TO/output/host/opt/ext-toolchain/bin/arm-linux-gnueabihf-

3. Build the drivers:

		make -j${nproc}

# Transfer data to media

1. Mount the media:

		sudo mount /dev/sdX1 /mnt/

2. The copy the drivers and blobs to system:

	For USB module:

		sudo cp wlan-usb.ko /mnt/lib/modules/4.1.15/extra/
		sudo cp -r firmware/usb/* /mnt/lib/firmware/

	For SDIO module:

		sudo cp wlan-sdio.ko /mnt/lib/modules/4.1.15/extra/
		sudo cp -r firmware/sdio/* /mnt/lib/firmware/

3. Unmount partition

		sudo umount /mnt/

# Booting

Now can unplug the media and plug it to the board.
Prepare the serial connection to the device (guide provided above) and power up the device.
The device should load the operating system. 
Default user login is `root
You can load the modules for beans with commands:

USB module:

	modprobe cfg80211
	insmod /lib/modules/4.1.15/extra/wlan-usb.ko

SDIO module:

	modprobe cfg80211
	insmod /lib/modules/4.1.15/extra/wlan-sdio.ko
