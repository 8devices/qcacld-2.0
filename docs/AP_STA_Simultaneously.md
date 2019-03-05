How to use AP and STA simultaneously
=====================================

1. Load the driver, if it's not loaded.

		insmod wlan.ko

2. Find out `phy` name. Our case - `phy0`

		# iw list | grep Wiphy
		Wiphy phy0

3. Add new interface

		iw phy phy0 interface add wlan1 type managed

4. Create [wpa_supplicant](wpa_supplicant_guide.md) and [hostapd](https://wiki.gentoo.org/wiki/Hostapd) config

	 Create wpa_supplicant and hostapd config. AP and STA can be configured to work on different channels on a different frequency band, 2.4 GHz and 5 GHz. For example, STA connects to AP on channel 1 and AP operates on channel 48. 

5. Run the applications

		wpa_supplicant -iwlan0 -c/etc/wpa_supplicant.conf &
		hostapd AP_configuration.conf
