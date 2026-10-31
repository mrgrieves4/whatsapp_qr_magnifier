import CoreGraphics
import Vision

/// Finds a QR code in an image and returns the text it holds.
enum QRCodeReader {
    static func firstPayload(in image: CGImage) throws -> String? {
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        try VNImageRequestHandler(cgImage: image).perform([request])
        return request.results?.lazy.compactMap(\.payloadStringValue).first
    }
}
