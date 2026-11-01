# QR Magnifier

A small macOS app that makes the WhatsApp for Mac login QR code easy to scan, especially with VoiceOver.

It watches the WhatsApp window once a second, reads the QR code with Apple's Vision framework, and redraws it large, black on white, in the middle of a window that fills the screen. When WhatsApp swaps in a new code (about every 20 seconds) the big copy updates and VoiceOver announces "QR code updated". When the code disappears after you link, it tells you so.

The code is only redrawn on your screen. It is never saved, logged, or sent anywhere.

## Installing

1. Download `QRMagnifier-<version>.zip` from the [Releases page](https://github.com/mrgrieves4/whatsapp_qr_magnifier/releases).
2. Unzip it and move `QRMagnifier.app` to your Applications folder.
3. Open it. Because the app isn't notarised by Apple, macOS says it can't verify it. Choose **Done** (not Move to Bin).
4. Open System Settings → Privacy & Security, go to the Security section near the bottom, and choose **Open Anyway** next to the message about QRMagnifier. Confirm with your password or Touch ID. You only need to do this once.

If you're comfortable with Terminal, this one command does the same as steps 3 and 4:

```bash
xattr -dr com.apple.quarantine /Applications/QRMagnifier.app
```

Works on macOS 15.6 or later, on Apple silicon and Intel Macs.

## Using it

1. Open WhatsApp on your Mac and press **Continue** so the QR code shows.
2. Open **QR Magnifier**. The first time, macOS asks for Screen Recording permission. Turn it on in System Settings → Privacy & Security → Screen & System Audio Recording, then quit and reopen QR Magnifier.
3. On your phone, open WhatsApp → Settings → Linked devices → Link a device, and point the camera at the middle of the Mac's screen.

The WhatsApp window can sit behind QR Magnifier; it doesn't need to be visible.

## Building

Requires macOS 15.6 or later, Xcode, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
make build   # Debug build to build/Build/Products/Debug/QRMagnifier.app
make run     # build, then open the Debug app
make test    # run the unit tests
make dist    # Release build zipped to dist/QRMagnifier-<version>.zip
make clean   # remove build output
```

Each `make` run regenerates the Xcode project from `project.yml` first. Debug builds are signed ad hoc; because the signature changes with each build, macOS may ask for Screen Recording permission again after a rebuild.

## Releasing

1. Bump `MARKETING_VERSION` in `project.yml`.
2. Run `make dist`.
3. On GitHub, create a release with a tag such as `v0.1.0` and attach the zip from `dist/`.

## Layout

- `project.yml`: XcodeGen project definition (the `.xcodeproj` is generated)
- `src/App`: app entry point
- `src/Services`: window capture, QR reading and drawing, and the polling model
- `src/Views`: SwiftUI views
- `Tests`: XCTest unit tests
