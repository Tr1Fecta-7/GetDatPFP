FINALPACKAGE=1
export TARGET = iphone:clang:11.2:11.0
include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

TWEAK_NAME = GetDatPFP

GetDatPFP_FILES = Tweak.xm MBProgressHUD.m
GetDatPFP_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Discord"
