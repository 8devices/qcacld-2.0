QCA9377 driver
=====================================

This repo is for 8devices BLUE bean and RED bean drivers (wlan-usb.ko and wlan-sdio.ko).
Drivers Tested on Raspberry Pi3 with linux-4.4 kernel (Crosscompiled on Ubuntu 16.04)

Crosscompiling openwrt with qcaqcl driver guide:
-------------------------------------

Note: This example tested on ubuntu 16.04 for other linux versions could need some tuning.

1.Install build essencials:

    sudo apt-get install git build-essential libssl-dev libncurses5-dev unzip \
    gawk zlib1g-dev subversion mercurial wget

2.Run script (checkouts qcaqcl-2.0 driver, openwrt and builds them)

    wget -O - https://raw.githubusercontent.com/8devices/qcacld-2.0/caf-wlan/LNX.LEH.4.2.2.2/scripts/start.sh | /bin/sh

3.Clone openwrt image to card. CHANGE ${PATH_TO_SD_CARD}

    sudo dd if=openwrt-out/openwrt-brcm2708-bcm2710-rpi-3-ext4-sdcard.img of=${PATH_TO_SD_CARD}

4.Mount second partition of sd on /mnt/ext4

5.Run load_sdio_firmware.sh or load_usb_firmware.sh

    scripts/load_usb_firmware.sh

Or

    scripts/load_sdio_firmware.sh

Crosscompiling manual way:
-------------------------------------

For cross-compiling edit Makefile, set variables and build:

usb module:

    make wlan-usb -j4

sdio module:

    make wlan-sdio -j4

both modules:

    make -j4

Another way is to pass parameters directly eg:

    ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILER_PATH} KERNEL_SRC=${KERNEL_SRC_PATH} make -j4

Installing:
-------------------------------------

usb module:

    cp wlan-usb.ko cfg80211.ko /lib/modules/`uname -r`/
    cp wlan_firmware-usb/* /lib/firmware/

sdio module:

    cp wlan-sdio.ko cfg80211.ko /lib/modules/`uname -r`/
    cp wlan_firmware-sdio/* /lib/firmware/

Load modules
-------------------------------------

usb module:

    modprobe cfg80211
    modprobe wlan-usb

sdio module:

    modprobe cfg80211
    modprobe wlan-sdio
