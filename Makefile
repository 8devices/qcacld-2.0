# Uncomment and edits this if you want to change parameters
#
# ARCH =
# KERNEL_SRC =
# CROSS_COMPILE =

OPENWRT_DIR ?= "${PWD}/../openwrt"
KERNEL_SRC ?= ${OPENWRT_DIR}/build_dir/target-arm_cortex-a53+neon-vfpv4_musl-1.1.14_eabi/linux-brcm2708_bcm2710/linux-4.4.4

export ARCH ?= arm
export STAGING_DIR = ${OPENWRT_DIR}/staging_dir
export CROSS_COMPILE ?= ${OPENWRT_DIR}/staging_dir/toolchain-arm_cortex-a53+neon-vfpv4_gcc-5.3.0_musl-1.1.14_eabi/bin/arm-openwrt-linux-

KBUILD_OPTIONS := WLAN_ROOT=$(PWD)

# Determine if the driver license is Open source or proprietary
# This is determined under the assumption that LICENSE doesn't change.
# Please change here if driver license text changes.
LICENSE_FILE ?= $(PWD)/$(WLAN_ROOT)/CORE/HDD/src/wlan_hdd_main.c
WLAN_OPEN_SOURCE = $(shell if grep -q "MODULE_LICENSE(\"Dual BSD/GPL\")" \
		$(LICENSE_FILE); then echo 1; else echo 0; fi)

#By default build for CLD
WLAN_SELECT := CONFIG_QCA_CLD_WLAN=m
KBUILD_OPTIONS += CONFIG_QCA_WIFI_ISOC=0
KBUILD_OPTIONS += CONFIG_QCA_WIFI_2_0=1
KBUILD_OPTIONS += $(WLAN_SELECT)
KBUILD_OPTIONS += WLAN_OPEN_SOURCE=$(WLAN_OPEN_SOURCE)
KBUILD_OPTIONS += BUILD_DEBUG_VERSION=1
KBUILD_OPTIONS += CONFIG_CFG80211=m
KBUILD_OPTIONS += CONFIG_LINUX_QCMBR=y
KBUILD_OPTIONS += SAP_AUTH_OFFLOAD=1
KBUILD_OPTIONS += CONFIG_PER_VDEV_TX_DESC_POOL=1
KBUILD_OPTIONS += $(KBUILD_EXTRA) # Extra config if any

.NOTPARALLEL:

all: wlan-usb wlan-sdio

wlan-usb:
	$(MAKE) CONFIG_CLD_HL_USB_CORE=y -C $(KERNEL_SRC) M=$(shell pwd) modules $(KBUILD_OPTIONS) MODNAME=wlan-usb

wlan-sdio:
	$(MAKE) CONFIG_CLD_HL_SDIO_CORE=y -C $(KERNEL_SRC) M=$(shell pwd) modules $(KBUILD_OPTIONS) MODNAME=wlan-sdio

modules_install:
	$(MAKE) INSTALL_MOD_STRIP=1 -C $(KERNEL_SRC) M=$(shell pwd) modules_install

clean:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) clean

.PHONY: all wlan-usb wlan-sdio modules_install clean
