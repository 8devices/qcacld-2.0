#!/bin/sh

#Change to path were rootfs is mounted
ROOTFS=/mnt/ext4

set -e

[ -d "$ROOTFS/lib/firmware" ] || (echo $ROOTFS/lib/firmware not found, \
	have you mounted rootfs?; exit 1)

mkdir -p $ROOTFS/lib/firmware/wlan
cp wlan-sdio.ko openwrt-out/cfg80211.ko $ROOTFS/lib/modules/4.4.4/
cp -r wlan_firmware-sdio/* $ROOTFS/lib/firmware/
