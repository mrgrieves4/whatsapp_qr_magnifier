import CoreGraphics
import ScreenCaptureKit

enum ScanResult: Equatable {
    case permissionNeeded
    case whatsAppNotOpen
    case noCode
    case code(String)
}

/// Captures the WhatsApp window (even when it is covered by other windows)
/// and reads any QR code in it. Nothing is saved or logged.
struct WhatsAppWindowScanner {
    static let whatsAppBundleID = "net.whatsapp.WhatsApp"

    func scan() async -> ScanResult {
        guard CGPreflightScreenCaptureAccess() else { return .permissionNeeded }

        let content: SCShareableContent
        do {
            content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
        } catch {
            return .permissionNeeded
        }

        // WhatsApp also owns small helper windows; the login screen is the largest one.
        let window = content.windows
            .filter { $0.owningApplication?.bundleIdentifier == Self.whatsAppBundleID }
            .filter { $0.frame.width >= 200 && $0.frame.height >= 200 }
            .max { $0.frame.width * $0.frame.height < $1.frame.width * $1.frame.height }
        guard let window else { return .whatsAppNotOpen }

        let filter = SCContentFilter(desktopIndependentWindow: window)
        let configuration = SCStreamConfiguration()
        let scale = CGFloat(filter.pointPixelScale)
        configuration.width = Int(filter.contentRect.width * scale)
        configuration.height = Int(filter.contentRect.height * scale)
        configuration.showsCursor = false

        do {
            let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
            if let payload = try QRCodeReader.firstPayload(in: image) {
                return .code(payload)
            }
            return .noCode
        } catch {
            return .noCode
        }
    }
}
