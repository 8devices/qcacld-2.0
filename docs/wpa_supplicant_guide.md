How to connect to AP with wpa_supplicant
=====================================

1. Load the driver, if it's not loaded.

		insmod wlan.ko

2. Create minimal wpa_supplicant configuration file:

	Edit and paste this configuration to `/etc/wpa_supplicant.conf`

		network={
				ssid="AP SSID"
				scan_ssid=1
				psk="Password"
		}

3. Start wpa_supplicant:

		wpa_supplicant -iwlan0 -c/etc/wpa_supplicant.conf
