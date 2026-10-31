import SwiftUI

struct ContentView: View {
    @StateObject private var model = QRMirrorModel()

    var body: some View {
        VStack(spacing: 20) {
            Text(model.statusMessage)
                .font(.title2)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if model.status == .permissionNeeded {
                Button("Open Screen Recording Settings") {
                    model.openScreenRecordingSettings()
                }
                .controlSize(.large)
            }

            if let image = model.qrImage {
                Image(image, scale: 1, label: Text("Enlarged WhatsApp QR code"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(32)
                    .background(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Spacer(minLength: 0)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .task { model.start() }
        .onDisappear { model.stop() }
    }
}
