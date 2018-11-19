Compile qcacld driver for Android x86
=====================================

1. Prepare build environment by official android [guide](https://source.android.com/setup/build/initializing)

2. Install Repo

		mkdir ~/bin
		PATH=~/bin:$PATH
		curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
		chmod a+x ~/bin/repo

3. Checkout android sources

		mkdir android-x86; cd android-x86
		repo init -u git://git.osdn.net/gitroot/android-x86/manifest -b oreo-x86
		repo sync --no-tags --no-clone-bundle

4. Prepare android build

		. build/envsetup.sh
		lunch android_x86-eng

5. Checkout QCA9377 sources

		cd ..
		git clone https://github.com/8devices/qcacld-2.0
		cd qcacld-2.0

6. Build qca driver

		PATH=$ANDROID_BUILD_PATHS$PATH KERNEL_SRC=$ANDROID_BUILD_TOP/out/target/product/x86/obj/kernel/ ARCH=x86 CROSS_COMPILE=$ANDROID_TOOLCHAIN/x86_64-linux-android-  make wlan-usb -j4

7. Edit android sources to include blobs:

		$EDITOR $ANDROID_BUILD_TOP/device/generic/common/x86.mk

	Change LOCAL_PATH variable accordingly to path of qca driver source folder and append to file:

		LOCAL_PATH=/CHANGE/PATH/HERE/
		# qcacld driver usb blobs:
		PRODUCT_COPY_FILES := \
		    $(LOCAL_PATH)/firmware/usb/utf.bin:root/lib/firmware/utf.bin \
		    $(LOCAL_PATH)/firmware/usb/athwlan.bin:root/lib/firmware/athwlan.bin \
		    $(LOCAL_PATH)/firmware/usb/otp.bin:root/lib/firmware/otp.bin \
		    $(LOCAL_PATH)/firmware/usb/fakeboar.bin:root/lib/firmware/fakeboar.bin \
		    $(LOCAL_PATH)/firmware/usb/wlan/usb_qcom_cfg.ini:root/lib/firmware/wlan/usb_qcom_cfg.ini \
		    $(LOCAL_PATH)/firmware/usb/wlan/usb_cfg.dat:root/lib/firmware/wlan/usb_cfg.dat \
		    $(LOCAL_PATH)/firmware/usb/qca61x4.bin:root/lib/firmware/qca61x4.bin \
		    $(LOCAL_PATH)/wlan-usb.ko:root/lib/modules/wlan-usb.ko \
		    $(PRODUCT_COPY_FILES)

8. Build android image

		cd $ANDROID_BUILD_TOP
		m -j4 iso_img

9. In booted image, insert module with

		insmod /lib/modules/wlan-usb.ko


Sources for more information:
http://www.android-x86.org/releases/releasenote-8-1-rc1
https://source.android.com/setup/build/initializing

