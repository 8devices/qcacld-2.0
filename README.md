QCA9377 driver
=====================================

This repo is for 8devices BLUE bean and RED bean drivers (wlan-usb.ko and wlan-sdio.ko).
Drivers Tested on Raspberry Pi3 with linux-4.4 kernel (cross-compiled on Ubuntu 16.04)

Compile Android with qcacld driver
-------------------------------------

1.Checkout Android Sources

    repo init -u https://android.googlesource.com/platform/manifest -b android-7.1.2_r36
    git clone https://github.com/android-rpi/local_manifests .repo/local_manifests
    repo sync

2.Setup env variables

    source build/envsetup.sh
    lunch rpi3-eng

3.Build Kernel

    cd kernel/rpi
    ARCH=arm scripts/kconfig/merge_config.sh arch/arm/configs/bcm2709_defconfig android/configs/android-base.cfg android/configs/android-recommended.cfg
    PATH=$ANDROID_BUILD_PATHS$PATH ARCH=arm CROSS_COMPILE=arm-linux-androideabi- make zImage dtbs -j4

4.Checkout qcacld-2.0 drivers

    git clone https://github.com/8devices/qcacld-2.0.git
    cd qcacld-2.0

5.Build qcacld-driver module

USB:

    PATH=$ANDROID_BUILD_PATHS$PATH KERNEL_SRC=$ANDROID_BUILD_TOP/kernel/rpi/ ARCH=arm CROSS_COMPILE=arm-linux-androideabi- make wlan-usb -j4

SDIO:

    PATH=$ANDROID_BUILD_PATHS$PATH KERNEL_SRC=$ANDROID_BUILD_TOP/kernel/rpi/ ARCH=arm CROSS_COMPILE=arm-linux-androideabi- make wlan-sdio -j4

Both:

    PATH=$ANDROID_BUILD_PATHS$PATH KERNEL_SRC=$ANDROID_BUILD_TOP/kernel/rpi/ ARCH=arm CROSS_COMPILE=arm-linux-androideabi- make -j4


6.Include driver into Android build system

    mkdir $ANDROID_BUILD_TOP/device/brcm/rpi3/firmware/qcacld-2.0
    ln -s $PWD/firmware/{usb,sdio} $ANDROID_BUILD_TOP/device/brcm/rpi3/firmware/qcacld-2.0
    ln -s $PWD/wlan-{usb,sdio}.ko $ANDROID_BUILD_TOP/device/brcm/rpi3/firmware/qcacld-2.0

7.Patch for auto-loading

    patch -p1 -d $ANDROID_BUILD_TOP/device/brcm/rpi3/ < android-patches/0001-load-usb-driver.patch
    patch -p1 -d $ANDROID_BUILD_TOP/device/brcm/rpi3/ < android-patches/0002-add-usb-blobs.patch

or

    patch -p1 -d $ANDROID_BUILD_TOP/device/brcm/rpi3/ < android-patches/0003-load-sdio-driver.patch
    patch -p1 -d $ANDROID_BUILD_TOP/device/brcm/rpi3/ < android-patches/0004-add-sdio-blobs.patch

8.Build Android source

    make ramdisk systemimage -j4

9.Prepare SD card

    Partitions of the card should be set-up like followings.
    p1 512MB for BOOT : Do fdisk : W95 FAT32(LBA) & Bootable, mkfs.vfat
    p2 512MB for /system : Do fdisk, new primary partition
    p3 512MB for /cache  : Do fdisk, mkfs.ext4
    p4 remainings for /data : Do fdisk, mkfs.ext4

10.Mount BOOT partition as /mnt/p1 then copy files

    cp $ANDROID_BUILD_TOP/device/brcm/rpi3/boot/* to /mnt/p1/
    cp $ANDROID_BUILD_TOP/kernel/rpi/arch/arm/boot/zImage /mnt/p1/
    cp $ANDROID_BUILD_TOP/kernel/rpi/arch/arm/boot/dts/bcm2710-rpi-3-b.dtb /mnt/p1/
    cp $ANDROID_BUILD_TOP/kernel/rpi/arch/arm/boot/dts/overlays/vc4-kms-v3d.dtbo to /mnt/p1/overlays/vc4-kms-v3d.dtbo
    cp $ANDROID_BUILD_TOP/out/target/product/rpi3/ramdisk.img /mnt/p1/

11.Write system partition

    sudo dd if=$ANDROID_BUILD_TOP/out/target/product/rpi3/system.img of=/dev/<p2> bs=1M

12.Connect to AP append /data/misc/wifi/wpa_supplicant.conf with your network configuration

    adb pull /data/misc/wifi/wpa_supplicant.conf /tmp/
    wpa_passphrase $SSID $PASSWORD >> /tmp/wpa_supplicant.conf
    adb shell svc wifi enable

Compile OpenWRT with qcacld driver
-------------------------------------

Note: This example tested on Ubuntu 16.04 other Linux versions may need some tuning.

1.Install build essentials:

    sudo apt-get install git build-essential libssl-dev libncurses5-dev unzip \
    gawk zlib1g-dev subversion mercurial wget

2.Run script (checkouts qcacld-2.0 driver, OpenWRT and builds them)

    wget -O - https://raw.githubusercontent.com/8devices/qcacld-2.0/caf-wlan/LNX.LEH.4.2.2.2/scripts/start.sh | /bin/sh

3.Clone OpenWRT image to card. CHANGE ${PATH_TO_SD_CARD}

    sudo dd if=openwrt-out/openwrt-brcm2708-bcm2710-rpi-3-ext4-sdcard.img of=${PATH_TO_SD_CARD}

4.Mount second partition of sd on /mnt/ext4

5.Run load_sdio_firmware.sh or load_usb_firmware.sh

    scripts/load_usb_firmware.sh

Or

    scripts/load_sdio_firmware.sh

Compile manually:
-------------------------------------

For cross-compiling edit Makefile, set variables (ARCH, CROSS_COMPILE, KERNEL_SRC) and build:

    make -j4

Only USB or SDIO module:

    make wlan-usb -j4
    make wlan-sdio -j4

Another way is to pass parameters directly eg:

    ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILER_PATH} KERNEL_SRC=${KERNEL_SRC_PATH} make -j4

### Install

USB module:

    cp wlan-usb.ko cfg80211.ko /lib/modules/`uname -r`/
    cp wlan_firmware-usb/* /lib/firmware/

SDIO module:

    cp wlan-sdio.ko cfg80211.ko /lib/modules/`uname -r`/
    cp wlan_firmware-sdio/* /lib/firmware/

### Load modules

USB module:

    modprobe cfg80211
    modprobe wlan-usb

SDIO module:

    modprobe cfg80211
    modprobe wlan-sdio
