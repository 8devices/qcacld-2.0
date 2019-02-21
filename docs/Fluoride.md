Bluetooth 5 on Fluoride stack
=====================================

This guide will show, how to start Fluoride Bluetooth stack on Linux.

 - [Qualcomm official guide](https://developer.qualcomm.com/qfile/35614/80-yc636-1_b_qca6174a_qca9377_wlan_bluetooth_linux_x86_porting_guide.pdf "Qualcomm official guide")

To download sources, register to [Qualcomm developer page](https://developer.qualcomm.com/).
Then download it from [QCA9377-3](https://developer.qualcomm.com/hardware/qca9377-x/tools) page.

# Preparation

1. Extract the archive

		tar xf qca9377.lea_.3.0_qdn_r3000017.1.tgz
		cd QCA9377.LEA.3.0_QDN_r3000017.1

2. Change the AIO script to checkout the sources in working directory

	Edit file: `fixce/aio-gen/build/scripts/te-f30/aio_gen.te-f30`
	Change CLONE_KERNEL to CLONE_KERNEL=y
	Change the CLONE_KERNEL_PATH to CLONE_KERNEL_PATH=`/path/to/qca9377-lea-3-0_qca_oem.git`

	Edit file: `fixce/aio-gen/build/scripts/te-f30/release.te-f30`
	Change IF_TYPE to IF_TYPE=USB

3. Generate AIO work directory

		cd fixce/aio-gen
		./aio_gen_bit.sh -t te-f30 -w 4.0.11.213V -b FLUORIDE -i USB -k v4.11

# Build kernel

1. Configure Linux kernel

		cd linux-stable
		make menuconfig

	Load the configuration `load -> ok -> exit -> save`

	Enable these packages:

		CONFIG_NL80211_TESTMODE *
		CONFIG_CFG80211 M
		CONFIG_CFG80211_INTERNAL_REGDB *

	Also, make sure there other necessary drivers enabled in configuration. In our case we need just AHCI SATA support to mount root file system. So enable:

		Device Drivers > Serial ATA and Parallel ATA drivers (libata) > AHCI SATA support *

	After finishing configuration, save config and exit.

2. Build the kernel

		make -j $(nproc)

# Build AIO

1. Change kernel path

	Edit file: `fixce/AIO/build/scripts/te-f30/config.te-f30`
	Change KERNELPATH to KERNELPATH=`/path/to/qca9377-lea-3-0_qca_oem.git/linux-stable`

2. Do not treat warnings as errors

	Edit file: `fixce/AIO/drivers/qcacld-new/Kbuild`
	Delete `-Werror\`

3. Build the AIO

		cd fixce/AIO/build
		make

4. Rebuild the kernel 

		cd /path/to/qca9377-lea-3-0_qca_oem.git/linux-stable/
		make -j $(nproc)

# Boot the kernel

1. Prepare and compress the kernel

		cd /path/to/qca9377-lea-3-0_qca_oem.git/linux-stable/
		mkdir -p /tmp/kernel/boot/
		make install INSTALL_PATH=/tmp/kernel/boot/
		make modules_install INSTALL_MOD_PATH=/tmp/kernel/
		cd /tmp/kernel/
	
	Compress it:

		tar cf kernel.tar.gz boot lib

	For parallel compression use pigz:

		tar cf kernel.tar.gz boot lib --use-compress-program="pigz --fast --recursive"

2. Transfer the archive to target machine

	USB, Samba, etc.
	scp (Change IP address accordingly):

		scp kernel.tar.gz user@192.168.1.123:/tmp/

3. Extract the archive

		sudo tar xf kernel.tar.gz -C /

	Or with pigz:

		sudo tar xf kernel.tar.gz --use-compress-program="pigz" -C /

4. Boot the image

	In case of GRUB:
	
	Generate new grub config with custom kernel

		sudo grub-mkconfig -o /boot/grub/grub.cfg

	Edit the `/boot/grub/grub.config` file. Edit the `set default` line.
	Change with the new kernel id from options below.
	Our case:

		set default="gnulinux-advanced-57cd9a31-8849-4d0d-9e2f-08ca6009b5f4>gnulinux-4.11.0+-advanced-57cd9a31-8849-4d0d-9e2f-08ca6009b5f4"

	And reboot the machine.

# Move the project to target machine

1. Compress the project

		cd /path/to/qca9377-lea-3-0_qca_oem.git/cnss_host_LEA/
		tar cf cnss_proc.tar.gz cnss_proc

	With pigz:

		tar cf cnss_proc.tar.gz cnss_proc --use-compress-program="pigz --fast --recursive"

2. Transfer the archive to the target machine

	USB, Samba, etc.
	scp (Change IP address accordingly):

		scp cnss_proc.tar.gz user@192.168.1.123:/tmp/

3. Extract the archive

		sudo tar xf cnss_proc.tar.gz

	Or with pigz:

		sudo tar xf cnss_proc.tar.gz --use-compress-program="pigz"

4. Execute the script

		cd cnss_host_LEA/cnss_proc/fixce/AIO/build
		chmod 777 ./scripts/board-type/bt.sh
		sudo ./scripts/board-type/bt.sh

# Start Bluetooth

1. Disable the other Bluetooth stacks

		sudo systemctl stop bluetooth

2. Starting the Fluoride

	Open two terminals. In the first one:

		cd fixce/AIO/apps/bt_workspace/qcom-opensource/bt/property-ops
		sudo ./btproperty

	In the second one:

		cd fixce/AIO/apps/bt_workspace/qcom-opensource/bt/bt-app
		sudo ./main/btapp

	Aditional information, how to use and configure the Fluoride, is provided in the Qualcomm document.
