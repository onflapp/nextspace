# -*- mode: makefile-gmake -*-

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME =		Keyboard
BUNDLE_EXTENSION =	.preferences

$(BUNDLE_NAME)_PRINCIPAL_CLASS = Keyboard
$(BUNDLE_NAME)_STANDARD_INSTALL = no

Keyboard_LANGUAGES = \
	English

Keyboard_LOCALIZED_RESOURCE_FILES = \
	Keyboard.gorm \
	AddLayoutPanel.gorm \
	ModifierKeys.gorm

Keyboard_RESOURCE_FILES = \
	Resources/Keyboard.tiff \
	Resources/bundle.registry \
	Resources/LayoutSwitchKeys.plist \
	Resources/ComposeCharacterKey.plist \
	Resources/CapsLockKey.plist \
	Resources/Model.plist

Keyboard_OBJC_FILES = \
	Keyboard.m \
	AddLayoutPanel.m \
	Shortcuts.m \
	ModifierKeys.m

Keyboard_HEADERS = \
	Keyboard.h \
	AddLayoutPanel.h \
	Shortcuts.h \
	ModifierKeys.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
