ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = Actualprefs
Actualprefs_FILES = Actualprefs.mm
Actualprefs_INSTALL_PATH = /Library/PreferenceBundles
Actualprefs_FRAMEWORKS = UIKit
Actualprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Actualprefs.plist$(ECHO_END)
