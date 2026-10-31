SCHEME := QRMagnifier
APP_NAME := QRMagnifier
VERSION := $(shell awk '/MARKETING_VERSION:/ { print $$2; exit }' project.yml)
BUILD_DIR := build
DIST_DIR := dist
RELEASE_APP := $(BUILD_DIR)/Build/Products/Release/$(APP_NAME).app
ZIP := $(DIST_DIR)/$(APP_NAME)-$(VERSION).zip

.PHONY: all project build test release dist clean

all: build

# Regenerate the Xcode project from project.yml
project:
	xcodegen generate

# Debug build; also installs to /Applications
build: project
	xcodebuild -scheme $(SCHEME) -configuration Debug -derivedDataPath $(BUILD_DIR) build

test: project
	xcodebuild -scheme $(SCHEME) -configuration Debug -derivedDataPath $(BUILD_DIR) test

# Universal (Apple silicon and Intel) Release build
release: project
	xcodebuild -scheme $(SCHEME) -configuration Release -derivedDataPath $(BUILD_DIR) build

# Zip the Release app for a GitHub release
dist: release
	mkdir -p $(DIST_DIR)
	rm -f $(ZIP)
	ditto -c -k --keepParent $(RELEASE_APP) $(ZIP)
	@echo "Created $(ZIP)"

clean:
	rm -rf $(BUILD_DIR) $(DIST_DIR)
