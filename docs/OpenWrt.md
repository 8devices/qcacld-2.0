Compile qcacld driver for OpenWrt
=====================================

Note: This example tested on Ubuntu 16.04 other Linux versions may need some tuning.

1. Install build essentials:

		sudo apt-get install git build-essential libssl-dev libncurses5-dev unzip \
		gawk zlib1g-dev subversion mercurial wget

2. Run script (checkouts qcacld-2.0 driver, OpenWRT and builds them)

		wget -O - https://raw.githubusercontent.com/8devices/qcacld-2.0/caf-wlan/LNX.LEH.4.2.2.2/scripts/start.sh | /bin/sh

3. Clone OpenWRT image to card. CHANGE ${PATH_TO_SD_CARD}

		sudo dd if=openwrt-out/openwrt-brcm2708-bcm2710-rpi-3-ext4-sdcard.img of=${PATH_TO_SD_CARD}

4. Mount second partition of sd on /mnt/ext4

5. Run load_sdio_firmware.sh or load_usb_firmware.sh

		scripts/load_usb_firmware.sh

	Or

		scripts/load_sdio_firmware.sh
