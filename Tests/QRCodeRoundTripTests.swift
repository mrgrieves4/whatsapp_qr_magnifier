import XCTest
@testable import QRMagnifier

final class QRCodeRoundTripTests: XCTestCase {
    func testRenderedCodeReadsBackToSamePayload() throws {
        let payload = "2@abcDEF123+/=,someKeyMaterial==,moreKeyMaterial==,1"
        let image = try XCTUnwrap(QRCodeRenderer.image(for: payload))
        XCTAssertEqual(try QRCodeReader.firstPayload(in: image), payload)
    }

    func testReaderReturnsNilForBlankImage() throws {
        let context = try XCTUnwrap(CGContext(
            data: nil, width: 200, height: 200, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue
        ))
        context.setFillColor(gray: 1, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        let image = try XCTUnwrap(context.makeImage())
        XCTAssertNil(try QRCodeReader.firstPayload(in: image))
    }
}
