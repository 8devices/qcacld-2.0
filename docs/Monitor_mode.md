How to use monitor mode
=====================================

1. Unload the driver if it was loaded before:

		rmmod wlan

2. Load the driver with the argument `con_mode=4`

		insmod wlan.ko con_mode=4

	After driver loading up sucessfuly, bring up the interface and check if it is in monitor mode:

		# ip link set wlan0 up
		# ip link show wlan0
		14: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 3000
			link/ieee802.11/radiotap c4:93:00:0f:c0:ad brd ff:ff:ff:ff:ff:ff

3. Set channel an channel width to monitor:

		iwpriv wlan0 setMonChan <channel> <channel width>
		# Valid channel width options: 0=20MHz, 1=40MHz, 2=80MHz
		# Ex: iwpriv wlan0 setMonChan 36 2

4. Start tcpdump:

		tcpdump -i wlan0 -w sniff.pacp

	This will create file which can be opened with wireshark. 

