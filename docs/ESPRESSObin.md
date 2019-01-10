Compile qcacld driver for ESPRESSObin
=====================================

Before compiling qcacld drivers for ESPRESSObin, you have to prepare kernel and buildroot file system. Here is official guides:
 - [Kernel building](http://wiki.espressobin.net/tiki-index.php?page=Build+From+Source+-+Kernel "ESPRESSObin Kernel guide")
 - [Buildroot file system](http://wiki.espressobin.net/tiki-index.php?page=Build+From+Source+-+Buildroot "ESPRESSObin Buildroot filesystem guide")
 - [Toolchain preparation](http://wiki.espressobin.net/tiki-index.php?page=Build+From+Source+-+Toolchain "ESPRESSObin toolchain download guide")
 - [Booting from USB](http://wiki.espressobin.net/tiki-index.php?page=Boot+from+removable+storage+-+Buildroot "ESPRESSObin booting from USB device")

The main purpose of this guide is to show, how to get started with Red Bean on ESPRESSObin board.

# Preparing Toolchain

1. Create folder and download the toolchain

		mkdir -p toolchain
		cd toolchain/
		wget https://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-2/aarch64-linux-gnu/gcc-linaro-5.2-2015.11-2-x86_64_aarch64-linux-gnu.tar.xz

2. Extract the archive

		tar -xvf gcc-linaro-5.2-2015.11-2-x86_64_aarch64-linux-gnu.tar.xz

3. Add toolchain to path. Change your path to toolchain accordingly

		export PATH=$PATH:/home/espressobin/toolchain/gcc-linaro-5.2-2015.11-2-x86_64_aarch64-linux-gnu/bin

# Preparing kernel sources

1. Create folder and download the sources

		mkdir -p kernel/4.4.52
		cd kernel/4.4.52/
		git clone -b linux-4.4.52-armada-17.06 https://github.com/MarvellEmbeddedProcessors/linux-marvell .

2. Apply official ESPRESSObin kernel [patches](http://wiki.espressobin.net/tiki-download_file.php?fileId=150 "Official ESPRESSObin kernel patches for armada-17.06")

		wget -O kernel_patches.zip "wiki.espressobin.net/tiki-download_file.php?fileId=150"
		unzip kernel_patches.zip
		git apply kernel_patches/0001-fix-regulator-armada-37xx-overwrite-CPU-voltage-valu.patch
		git apply kernel_patches/0002-fix-ARM64-dts-marvell-armada-37xx-update-CPU-voltage.patch

3. Copy and apply the patches qcacld drivers folder

		cp ../../qcacld-2.0/patches/Marvell-ESPRESSObin/0003-qcacld-gpio-stdio-voltage.patch .
		cp ../../qcacld-2.0/patches/Marvell-ESPRESSObin/0004-qcacld-64bit-kernel.patch .
		git apply 0003-qcacld-gpio-stdio-voltage.patch
		git apply 0004-qcacld-64bit-kernel.patch

4. Export the environment variables

		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-

5. Create default kernel configuration file

		make mvebu_v8_lsp_defconfig

6. Configure kernel configure file to add cfg80211 modules

		make menuconfig
	
	In the menu config:
	
		Networking support -> Wireless Enable it
		Wireless -> cfg80211
		Wireless -> nl80211
		Wireless -> cfg80211 wireless extensions compatibility
		Wireless -> Generic IEEE 802.11 Networking Stack (mac80211)
	
	Save and exit

7. Start building kernel

		make -j4

If the build process finishes successfully, you can find the Image in `arch/arm64/boot/` and device tree blob (armada-3720-community.dtb) in `arch/arm64/boot/dts/marvell/`

# Preparing buildroot file system

1. Create folder and download the sources

		mkdir buildroot
		cd buildroot/
		git clone -b buildroot-2015.11-16.08 https://github.com/MarvellEmbeddedProcessors/buildroot-marvell .

2. Make a default configuration file

		make mvebu_armv8_le_defconfig

3. Configure buildroot

		make menuconfig

	In menuconfig, select Toolchain and there configure the following (note that some of these settings might be pre-configured already):

		Toolchain Type -> External toolchain
		Toolchain -> Custom toolchain
		Toolchain origin -> Pre-installed toolchain
		Toolchain path -> path-to-linaro-toolchain-excluding-bin
		Here set the compiler path as you have configured it when following Toolchain tutorial but excluding the /bin directory (in our case the path was /home/espressobin/toolchain/gcc-linaro-5.2-2015.11-2-x86_64_aarch64-linux-gnu/)
		Toolchain prefix -> aarch64-linux-gnu
		Here we set the toolchain prefix excluding the last "-", so this should be aarch64-linux-gnu
		External toolchain gcc version --> 5.x
		External toolchain kernel headers series -> 4.0.x
		Here we set the correct toolchain kernel header series. The toolchain used for building ESPRESSObin Buildroot (as we demonstrated in Toolchain) is Linaro gcc 5.2.1 which uses kernel header 4.0.x 

	After setting up the toolchain, additionaly can add other packages to. In our case we only added:

		Target packages -> Networking applications -> iw
		Target packages -> Networking applications -> wpa_supplicant

		Save the .config and exit.

4. Apply ESPRESSObin path to buildroot

		cp ../../qcacld-2.0/patches/Marvell-ESPRESSObin/Buildroot-fio-reop.patch .
		patch -p1 < Buildroot-fio-reop.patch

5. Start building root file system

		make -j4

If the build process finishes successfully, you can find the files in `output/images/`

# Building qcacld driver

1. Download the sources

		git clone https://github.com/8devices/qcacld-2.0
		cd qcacld-2.0

2. Edit variables in the make file ARCH, KERNEL_SRC, CROSS_COMPILE accordingly. For example:

		ARCH = arm64
		KERNEL_SRC = /hdd/user/Marvell_Armada_3700LP/kernel/4.4.52
		CROSS_COMPILE = /hdd/user/Marvell_Armada_3700LP/toolchain/gcc-linaro-5.2-2015.11-2-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

3. Start building the qcacld driver

		make -j4

If the build process finishes successfully, you can find the files (wlan-sdio.ko) should be in `qcacld-2.0` directory

# Prepare USB drive

Prepare USB drive to format it and boot from it. Any USB drive above 1GB of storage will do.

1. Wipe the USB drive

	As pluged the drive, our computer labeled it as `/dev/sdb`. Be careful and check the all drives with `fdisk -l` command.

		sudo dd if=/dev/zero of=/dev/sdb bs=1M count=100

2. Create partition

		(echo n; echo p; echo 1; echo ''; echo ''; echo w) | sudo fdisk /dev/sdb

3. Make file system on it

		sudo mkfs.ext4 /dev/sdb1

4. Make directory and mount the drive on it

		sudo mkdir -p /mnt/sdcard
		sudo mount /dev/sdb1 /mnt/sdcard

5. Choose mounted directory and extract file system on it

		cd /mnt/sdcard
		sudo tar -xvf /hdd/user/Marvell_Armada_3700LP/buildroot/output/images/rootfs.tar.gz

6. Make boot directory, copy the kernel and device tree

		sudo mkdir -p boot
		sudo cp /hdd/user/Marvell_Armada_3700LP/kernel/4.4.52/arch/arm64/boot/Image boot/
		sudo cp /hdd/user/Marvell_Armada_3700LP/kernel/4.4.52/arch/arm64/boot/dts/marvell/armada-3720-community.dtb boot/

7. Copy compiled qcacld driver to root folder

		sudo cp ../../qcacld-2.0/wlan-sdio.ko ../root/

8. Change working directory and unmount the USB drive

		cd
		sudo umount /mnt/sdcard

#Booting from USB

1. Connect USB cable to ESPRESSObin and check, how connection is named

		dmesg | tail

	The output sould be similar to:

		[86000.246258] pl2303 2-1.3:1.0: device disconnected
		[86001.904945] usb 2-1.3: new full-speed USB device number 11 using ehci-pci
		[86002.057267] pl2303 2-1.3:1.0: pl2303 converter detected
		[86002.059323] usb 2-1.3: pl2303 converter now attached to ttyUSB0

	Our case: ttyUSB0

2. Open serial communication program. In example will be used `picocom`.

		picocom -b 115200 /dev/ttyUSB0

3. Plug the external power to the board

	After this, there should be pouring text, when there will be `Hit any key to stop autoboot` - hit any key
	Then should be in bootloader

4. Plug the created USB device into USB2 port. Verify that it's recognized

		usb start
		ext4ls usb 0:1 boot

	The output should look like:

		Hit any key to stop autoboot:  0
		Marvell>> usb start
		starting USB...
		USB0:   Register 2000104 NbrPorts 2
		Starting the controller
		USB XHCI 1.00
		USB1:   USB EHCI 1.00
		scanning bus 0 for devices... 1 USB Device(s) found
		scanning bus 1 for devices... 2 USB Device(s) found
			   scanning usb for storage devices... 1 Storage Device(s) found
		Marvell>> ext4ls usb 0:1 boot
		<DIR>       4096 .
		<DIR>       4096 ..
				13352960 Image
				   11343 armada-3720-community.dtb
		Marvell>>

5. Set environment variables

		setenv image_name boot/Image
		setenv fdt_name boot/armada-3720-community.dtb
		setenv bootusb 'usb start;ext4load usb 0:1 $kernel_addr $image_name;ext4load usb 0:1 $fdt_addr $fdt_name;setenv bootargs $console root=/dev/sda1 rw rootwait; booti $kernel_addr - $fdt_addr'
		saveenv

6. Run the command

		run bootusb

7. Login and insert module

	If everything was done correctly, should be greeted with:

		Welcome to Buildroot
		buildroot login:

	Default login name `root`. To insert module, use `insmod wlan-sdio.ko` command

		Welcome to Buildroot
		buildroot login: root
		# insmod wlan-sdio.ko

	The interface `wlan0` and `p2p0` should be created:

		# ip l
		1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
			link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
		2: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
			link/ether 32:22:84:41:5d:8f brd ff:ff:ff:ff:ff:ff
		3: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 532
			link/ether f0:ad:4e:04:96:3a brd ff:ff:ff:ff:ff:ff
		4: sit0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default qlen 1
			link/sit 0.0.0.0 brd 0.0.0.0
		5: wan@eth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop switchid 00000000 state DOWN mode DEFAULT group default qlen 1000
			link/ether f0:ad:4e:04:96:3a brd ff:ff:ff:ff:ff:ff
		6: lan0@eth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop switchid 00000000 state DOWN mode DEFAULT group default qlen 1000
			link/ether f0:ad:4e:04:96:3a brd ff:ff:ff:ff:ff:ff
		7: lan1@eth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop switchid 00000000 state DOWN mode DEFAULT group default qlen 1000
			link/ether f0:ad:4e:04:96:3a brd ff:ff:ff:ff:ff:ff
		8: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
			link/ether c4:93:00:0f:93:6a brd ff:ff:ff:ff:ff:ff
		9: p2p0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
			link/ether c6:93:00:90:93:6a brd ff:ff:ff:ff:ff:ff


