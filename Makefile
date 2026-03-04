APP_NAME = Jobcan
BUNDLE_DIR = build/$(APP_NAME).app
CONTENTS_DIR = $(BUNDLE_DIR)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
BUILD_DIR = .build/release

.PHONY: build bundle sign install uninstall clean run

build:
	swift build -c release --arch arm64

bundle: build
	mkdir -p $(MACOS_DIR) $(CONTENTS_DIR)/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(MACOS_DIR)/
	cp Resources/Info.plist $(CONTENTS_DIR)/
	cp Resources/AppIcon.icns $(CONTENTS_DIR)/Resources/

sign: bundle
	codesign --force --sign - $(BUNDLE_DIR)

install: sign
	cp -R $(BUNDLE_DIR) /Applications/
	xattr -dr com.apple.quarantine /Applications/$(APP_NAME).app

uninstall:
	rm -rf /Applications/$(APP_NAME).app

clean:
	rm -rf build .build

run: sign
	open $(BUNDLE_DIR)
