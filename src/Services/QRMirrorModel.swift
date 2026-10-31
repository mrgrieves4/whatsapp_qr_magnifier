import AppKit
import SwiftUI

/// Polls the WhatsApp window once a second and keeps an enlarged copy of its QR code.
@MainActor
final class QRMirrorModel: ObservableObject {
    enum Status: Equatable {
        case starting
        case permissionNeeded
        case whatsAppNotOpen
        case waitingForCode
        case showingCode
        case codeGone
    }

    @Published private(set) var status: Status = .starting
    @Published private(set) var qrImage: CGImage?

    /// A single missed frame shouldn't make the code vanish, so wait for a few in a row.
    private static let missesBeforeGone = 3

    private let scanner = WhatsAppWindowScanner()
    private var payload: String?
    private var missCount = 0
    private var pollTask: Task<Void, Never>?

    var statusMessage: String {
        switch status {
        case .starting:
            return "Looking for WhatsApp…"
        case .permissionNeeded:
            return "QR Magnifier needs Screen Recording permission to see the WhatsApp window. Turn it on in System Settings, then quit and reopen QR Magnifier."
        case .whatsAppNotOpen:
            return "WhatsApp isn't open. Open WhatsApp on your Mac and press Continue on its welcome screen."
        case .waitingForCode:
            return "WhatsApp is open but isn't showing a QR code yet."
        case .showingCode:
            return "Showing WhatsApp's QR code. Point your phone at the middle of the screen."
        case .codeGone:
            return "The QR code has gone. If you just linked your phone, you're done."
        }
    }

    func start() {
        guard pollTask == nil else { return }
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let scanner = self?.scanner else { return }
                let result = await scanner.scan()
                self?.apply(result)
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    func stop() {
        pollTask?.cancel()
        pollTask = nil
    }

    func openScreenRecordingSettings() {
        // Shows the system prompt the first time; after that only Settings can grant it.
        if !CGRequestScreenCaptureAccess(),
           let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    private func apply(_ result: ScanResult) {
        switch result {
        case .code(let newPayload):
            missCount = 0
            guard newPayload != payload else { return }
            let wasShowing = status == .showingCode
            payload = newPayload
            qrImage = QRCodeRenderer.image(for: newPayload)
            setStatus(.showingCode)
            announce(wasShowing ? "QR code updated" : "QR code found. Point your phone at the middle of the screen.")
        case .noCode:
            if status == .showingCode {
                missCount += 1
                guard missCount >= Self.missesBeforeGone else { return }
                clearCode()
                setStatus(.codeGone)
                announce(statusMessage)
            } else if status != .codeGone {
                setStatus(.waitingForCode, announcing: true)
            }
        case .whatsAppNotOpen:
            clearCode()
            setStatus(.whatsAppNotOpen, announcing: true)
        case .permissionNeeded:
            clearCode()
            setStatus(.permissionNeeded, announcing: true)
        }
    }

    private func clearCode() {
        payload = nil
        qrImage = nil
        missCount = 0
    }

    private func setStatus(_ newStatus: Status, announcing: Bool = false) {
        guard newStatus != status else { return }
        status = newStatus
        if announcing {
            announce(statusMessage)
        }
    }

    private func announce(_ message: String) {
        var text = AttributedString(message)
        text.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(text).post()
    }
}
