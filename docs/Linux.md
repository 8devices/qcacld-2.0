Compile qcacld driver for Linux
=====================================

For cross-compiling edit `scripts/start.sh`, set variables (ARCH, CROSS_COMPILE, KERNEL_SRC) and build:

    ./scripts/start.sh

Another way is to pass parameters directly eg:

    ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILER_PATH} KERNEL_SRC=${KERNEL_SRC_PATH} make -j4

To compile only USB or SDIO, use arguments:

For USB:

    ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILER_PATH} KERNEL_SRC=${KERNEL_SRC_PATH} make -j4 wlan-usb

For SDIO:

    ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILER_PATH} KERNEL_SRC=${KERNEL_SRC_PATH} make -j4 wlan-sdio

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
