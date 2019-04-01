Compile qcacld driver for Ubuntu with 4.4.0-130 kernel
=====================================

Before building, make sure that:

* Kernel headers are installed
* cfg80211 module is present

Checkout the sources and build the driver:

	git clone https://github.com/8devices/qcacld-2.0 -b caf-wlan/LNX.LEH.4.2.2.2
	cd qcacld-2.0/
	make -j4

To compile only USB or SDIO, use arguments:

For USB:

	make -j4 wlan-usb

For SDIO:

	make -j4 wlan-sdio

### Install

USB module:

	cp wlan-usb.ko /lib/modules/`uname -r`/
	cp -r firmware/usb/* /lib/firmware/

SDIO module:

	cp wlan-sdio.ko /lib/modules/`uname -r`/
	cp -r firmware/sdio/* /lib/firmware/

### Load modules

USB module:

	modprobe cfg80211
	modprobe wlan-usb

SDIO module:

	modprobe cfg80211
	modprobe wlan-sdio
