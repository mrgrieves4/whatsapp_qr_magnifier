SCHEME := QRMagnifier
APP_NAME := QRMagnifier
VERSION := $(shell awk '/MARKETING_VERSION:/ { print $$2; exit }' project.yml)
BUILD_DIR := build
DIST_DIR := dist
DEBUG_APP := $(BUILD_DIR)/Build/Products/Debug/$(APP_NAME).app
RELEASE_APP := $(BUILD_DIR)/Build/Products/Release/$(APP_NAME).app
ZIP := $(DIST_DIR)/$(APP_NAME)-$(VERSION).zip

.PHONY: all project build run test release dist clean

all: build

# Regenerate the Xcode project from project.yml
project:
	xcodegen generate

# Debug build into build/
build: project
	xcodebuild -scheme $(SCHEME) -configuration Debug -derivedDataPath $(BUILD_DIR) build

# Build and open the Debug app
run: build
	open $(DEBUG_APP)

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
