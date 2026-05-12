PROJECT := AIDemos.xcodeproj
SCHEME := AIDemos
CONFIGURATION := Debug
DERIVED_DATA := .build/DerivedData
APP_PATH := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)/AIDemos.app

.PHONY: help macos-build macos-start clean

help:
	@echo "Targets:"
	@echo "  make macos-build   Build macOS app via xcodebuild"
	@echo "  make macos-start   Build and launch macOS app"
	@echo "  make clean         Remove local derived data"

macos-build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIGURATION) -destination 'platform=macOS' -derivedDataPath $(DERIVED_DATA) build

macos-start: macos-build
	open $(APP_PATH)

clean:
	rm -rf .build