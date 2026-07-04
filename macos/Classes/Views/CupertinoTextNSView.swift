import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoTextNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>

    private var payload: CNTextPayload?

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativeText_\(viewId)", binaryMessenger: messenger)
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
            guard let self else {
                result(nil)
                return
            }

            switch call.method {
            case "getIntrinsicSize":
                let size = hostingView.fittingSize
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setText":
                if let raw = CNChannelSerialization.asDict(call.arguments) {
                    payload = CNTextPayload(channel: raw)
                    rebuild()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing text payload", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func rebuild() {
        hostingView.rootView = payload.flatMap { payload in
            CNText.deserialize(payload.toChannel()) { [weak self] size in
                self?.channel.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": size.width, "height": size.height],
                )
            }
        } ?? AnyView(EmptyView())
    }
}
