import SwiftUI

@main
struct QRMagnifierApp: App {
    var body: some Scene {
        Window("QR Magnifier", id: "main") {
            ContentView()
        }
        // Fill the screen without native full screen, which would move the window
        // to its own Space away from WhatsApp.
        .defaultWindowPlacement { _, context in
            WindowPlacement(context.defaultDisplay.visibleRect.origin, size: context.defaultDisplay.visibleRect.size)
        }
    }
}
