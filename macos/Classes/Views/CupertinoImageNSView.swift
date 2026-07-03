import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoImageView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>

    private var payload: CNImagePayload?

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativeImage_\(viewId)", binaryMessenger: messenger)
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))

        payload = CNChannelSerialization.decode(args)

        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        rebuild()

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { result(nil); return }
            switch call.method {
            case "setImage":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    self.payload = CNImagePayload(channel: args)
                    self.rebuild()
                    result(nil)
                } else { result(FlutterError(code: "bad_args", message: "Missing args", details: nil)) }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    private func rebuild() {
        hostingView.rootView = payload.flatMap {
            CNImage.deserialize($0.toChannel())
        } ?? AnyView(EmptyView())
    }
}
