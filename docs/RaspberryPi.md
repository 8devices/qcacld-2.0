Compile qcacld driver for RaspberryPi
=====================================

Before compiling qcacld drivers for RaspberryPi, you have to prepare kernel. Here is official guide:
 - [Kernel building](https://www.raspberrypi.org/documentation/linux/kernel/building.md "RaspberryPi Kernel guide")

# Install Raspbian Stretch Lite to sdcard

1. Download Raspbian Stretch Lite image from [Raspberry official site](https://www.raspberrypi.org/downloads/raspbian/)

2. Unzip the image

		unzip 2018-11-13-raspbian-stretch-lite.zip

3. Write the sdcard

	Insert SD card and check the name

		sudo fdisk -l

	In our case, the sdcard was named `/dev/mmcblk0`, then 

		sudo dd if=2018-11-13-raspbian-stretch-lite.img of=/dev/mmcblk0

4. **Optional** Enable ssh

	Mount the sdcard boot partition

		sudo mount /dev/mmcblk0p1 /mnt

	Create file, [that enables ssh](https://www.raspberrypi.org/documentation/remote-access/ssh/)

		sudo touch /mnt/ssh

	Unmount the partition

		sudo umount /mnt

# Building the sources

1. Download sources

		mkdir RaspberryPi_Beans; cd RaspberryPi_Beans
		git clone https://github.com/raspberrypi/tools
		git clone https://github.com/raspberrypi/linux -b rpi-4.11.y
		git clone https://github.com/8devices/qcacld-2.0/ -b CNSS.LEA.NRT_3.0

2. Add toolchain to PATH

		export PATH=$PATH:$PWD/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin

3. Prepare Linux

		cd linux
		KERNEL=kernel7
		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig

	Enable nl80211 test mode:

		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig

		Networking support -> Wireless -> nl80211 testmode command

	Save and exit

4. Patch kernel

		for i in ../qcacld-2.0/patches/kernel/v4.11/0* ; do patch -p1 < $i ; done

5. Build kernel

		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs -j$(nproc)

6. Patch qcacld

		cd ../qcacld-2.0/

	Patch the sources

		patch -p1 < patches/RaspberryPi/0001-destructor_rename.patch

7. Build qcacld

		KERNEL_SRC=../linux/ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j$(nproc)
		cd ..

# Booting image

1. Mount boot partition

		sudo mount /dev/mmcblk0p1 /mnt

2. Transfer the kernel and device tree

		cd linux
		sudo cp /mnt/kernel7.img /mnt/kernel7-backup.img
		sudo cp arch/arm/boot/zImage /mnt/kernel7.img
		sudo cp arch/arm/boot/dts/*.dtb /mnt/
		sudo cp arch/arm/boot/dts/overlays/*.dtb* /mnt/overlays/
		sudo cp arch/arm/boot/dts/overlays/README /mnt/overlays/

3. Edit `/boot/config.txt`

		echo core_freq=250 | sudo tee --append /mnt/config.txt
		echo dtoverlay=sdio,poll_once=false | sudo tee --append /mnt/config.txt

4. Unmount the partition

		sudo umount /mnt

5. Install modules

		sudo mount /dev/mmcblk0p2 /mnt
		sudo make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=/mnt/ modules_install
		cd ../qcacld-2.0/
		sudo cp *.ko /mnt/home/pi/

	for USB:

		sudo cp -r firmware_bin/usb/* /mnt/lib/firmware/

	for SDIO:

		sudo cp -r firmware_bin/sdio/* /mnt/lib/firmware/

		sudo umount /mnt

6. Boot the image

	Insert the sdcard into Raspberry and power it up.

	Connect the device to the Raspberry and load module with command

		sudo insmod wlan-usb.ko

	or

		sudo insmod wlan-sdio.ko

	The interface should appear:

		pi@raspberrypi:~ $ ip l
		1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
			link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
		2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
			link/ether b8:27:eb:53:d0:9c brd ff:ff:ff:ff:ff:ff
		3: wlan0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DORMANT group default qlen 1000
			link/ether b8:27:eb:06:85:c9 brd ff:ff:ff:ff:ff:ff
		8: wlan1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DORMANT group default qlen 3000
			link/ether c4:93:00:0f:7e:58 brd ff:ff:ff:ff:ff:ff
		9: p2p0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DORMANT group default qlen 3000
			link/ether c6:93:00:90:7e:58 brd ff:ff:ff:ff:ff:ff


