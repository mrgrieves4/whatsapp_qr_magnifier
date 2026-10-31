import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

/// Draws a clean, high-contrast QR code for a payload.
enum QRCodeRenderer {
    /// Each QR module becomes a `moduleSize` square of pixels, so the image stays
    /// sharp when SwiftUI scales it up with interpolation turned off.
    static func image(for payload: String, moduleSize: CGFloat = 16) -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: moduleSize, y: moduleSize))
        return CIContext().createCGImage(scaled, from: scaled.extent)
    }
}
