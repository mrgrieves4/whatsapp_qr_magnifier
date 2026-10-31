# QR Magnifier

A small macOS app that makes the WhatsApp for Mac login QR code easy to scan, especially with VoiceOver.

It watches the WhatsApp window once a second, reads the QR code with Apple's Vision framework, and redraws it large, black on white, in the middle of a window that fills the screen. When WhatsApp swaps in a new code (about every 20 seconds) the big copy updates and VoiceOver announces "QR code updated". When the code disappears after you link, it tells you so.

The code is only redrawn on your screen. It is never saved, logged, or sent anywhere.

## Using it

1. Open WhatsApp on your Mac and press **Continue** so the QR code shows.
2. Open **QR Magnifier**. The first time, macOS asks for Screen Recording permission. Turn it on in System Settings → Privacy & Security → Screen & System Audio Recording, then quit and reopen QR Magnifier.
3. On your phone, open WhatsApp → Settings → Linked devices → Link a device, and point the camera at the middle of the Mac's screen.

The WhatsApp window can sit behind QR Magnifier; it doesn't need to be visible.

## Building

Requires macOS 15.6 or later, Xcode, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
xcodegen generate
xcodebuild -scheme QRMagnifier -configuration Debug build
xcodebuild -scheme QRMagnifier -configuration Debug test
```

Each build copies the app to `/Applications/QR Magnifier.app` and signs it ad hoc. Because the signature changes with each build, macOS may ask for Screen Recording permission again after a rebuild.

## Layout

- `project.yml`: XcodeGen project definition (the `.xcodeproj` is generated)
- `src/App`: app entry point
- `src/Services`: window capture, QR reading and drawing, and the polling model
- `src/Views`: SwiftUI views
- `Tests`: XCTest unit tests
