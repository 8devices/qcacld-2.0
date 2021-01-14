QCA9377 driver
=====================================

This repo is for 8devices BLUE bean and RED bean drivers (wlan-usb.ko and wlan-sdio.ko).
Drivers Tested on:

 - [ESPRESSObin board with 4.4.52-armada-17.06.2](docs/ESPRESSObin.md)
 - [NXP BD-SL-i.MX6](docs/NXP-BD-SL-i.MX6.md)
 - [RaspberryPi](docs/RaspberryPi.md)

The driver branches by kernel versions:

Branch [CNSS.LEA.NRT_3.0](https://github.com/8devices/qcacld-2.0/tree/CNSS.LEA.NRT_3.0):

 - v4.4.15
 - v4.9.11
 - v4.11

Branch [linux-4.19.y/CNSS.LEA.NRT_3.0](https://github.com/8devices/qcacld-2.0/tree/linux-4.19.y/CNSS.LEA.NRT_3.0):

 - v4.19.x

Branch [linux-5.4.y/CNSS.LEA.NRT_3.0](https://github.com/8devices/qcacld-2.0/tree/linux-5.4.y/CNSS.LEA.NRT_3.0):

 - v5.4.x
   Works on Ubuntu/20.04/LTS, RaspberryPi that runs Linux v5.4.0 kernel.

 On other kernel versions the results may vary. Pull requests are welcome!

Head over to docs directory for guides and documentation.

Other helpful resources:
 - [Bluetooth 5 on fluoride](docs/Fluoride.md)
 - [How to create access point](https://wiki.gentoo.org/wiki/Hostapd "How to create access point")
 - [How to use monitor mode](docs/Monitor_mode.md "How to use monitor mode")
 - [How to connect to protected access point](docs/wpa_supplicant_guide.md "How to connect to protected access point")
 - [How to run AP and STA simultaneously](docs/AP_STA_Simultaneously.md "How to run AP and STA simultaneously")
