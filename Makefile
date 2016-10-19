ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = RawBatt
RawBatt_FILES = Tweak.xm
RawBatt_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
