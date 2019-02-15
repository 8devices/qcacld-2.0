Compile qcacld driver for BD-SL-i.MX6
=====================================

Before compiling qcacld drivers for BD-SL-i.MX6, you have to prepare operating system. Here is official guides and useful links with information:
 - [Development board's vendor wiki](https://boundarydevices.com/wiki/ "Boundary devices wiki")
 - [Buildroot guide for i.MX platforms](https://boundarydevices.com/imx-linux-kernel-4-9-for-nitrogen-platforms/  "Buildroot preparation guide")
 - [Device's homepage](https://boundarydevices.com/product/sabre-lite-imx6-sbc/ "Specification for BD-SL-i.MX6")
 - [Console connection guide](https://boundarydevices.com/just-getting-started/ "How to connect serial console")

# Prepare Buildroot with kernel

1. Download the Buildroot and qcacld sources:

		git clone https://github.com/8devices/qcacld-2.0/ -b CNSS.LEA.NRT_3.0
		git clone https://github.com/buildroot/buildroot -b 2018.02.x
		cd buildroot/

2. Use default configuration for the board:

		make nitrogen6x_defconfig

3. Configure Linux:

		make linux-menuconfig

	Enable:

		Device Drivers -> Network device support -> Wireless LAN -> Intersil devices -> IEEE 802.11 for Host AP (M)

	Save and exit.

4. Configure buildroot:

		make menuconfig

	Here You can enable packages that You want to include in the filesystem (i.e. openssh, iw, etc.). Type `/` to search.
	Enable:

		Target packages -> Networking applications -> wireless tools
		Target packages -> Networking applications -> hostapd
		Target packages -> Networking applications -> wpa_supplicant
		Target packages -> Networking applications -> iw

	Save and exit.

5. Build the image:

		make linux -j${nproc}

6. Apply the kernel patch:

		cd output/build/linux-custom/
		patch -p1 < ../../../../qcacld-2.0/patches/NXP-i.MX6/0001-Disable-other-voltages-than-1.8V-for-SDIO.patch
		for i in ../../../../qcacld-2.0/patches/kernel/v4.9.11/* ; do patch -p1 < $i ; done
		cd ../../../

7. Rebuild the image:

		make -j${nproc}

	This will take some time.

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
		KERNEL_SRC=../buildroot/output/build/linux-custom/
		CROSS_COMPILE=../buildroot/output/host/bin/arm-buildroot-linux-uclibcgnueabihf-

3. Build the drivers:

		make -j${nproc}

# Transfer data to media

1. Mount the media:

		sudo mount /dev/sdX1 /mnt/

2. The copy the drivers and blobs to system:

	For USB module:

		sudo cp wlan-usb.ko /mnt/lib/modules/4.1.15/extra/
		sudo cp -r firmware_bin/usb/* /mnt/lib/firmware/

	For SDIO module:

		sudo cp wlan-sdio.ko /mnt/lib/modules/4.1.15/extra/
		sudo cp -r firmware_bin/sdio/* /mnt/lib/firmware/

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
