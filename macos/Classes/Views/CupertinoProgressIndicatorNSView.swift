import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoProgressIndicatorNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>

    private var payload: CNProgressViewPayload?

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))
        channel = FlutterMethodChannel(
            name: "CupertinoNativeProgressIndicator_\(viewId)", binaryMessenger: messenger,
        )
        payload = CNProgressViewDeserializer.decode(args)

        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        rebuild()
        setupChannel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }

            switch call.method {
            case "getIntrinsicSize":
                let size = hostingView.fittingSize
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setProgressView":
                if let parsed: CNProgressViewPayload = CNChannelSerialization.decode(call.arguments) {
                    payload = parsed
                    rebuild()
                    let size = hostingView.fittingSize
                    channel.invokeMethod(
                        "intrinsicSizeChanged",
                        arguments: ["width": Double(size.width), "height": Double(size.height)],
                    )
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Invalid progress view payload", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func rebuild() {
        guard let payload else {
            hostingView.rootView = AnyView(EmptyView())
            return
        }

        if let isDark = payload.isDark {
            hostingView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        } else {
            hostingView.appearance = nil
        }

        hostingView.rootView = CNProgressViewDeserializer.deserialize(
            payload.toChannel(),
            onSizeChanged: { [weak self] size in
                self?.channel.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": size.width, "height": size.height],
                )
            },
        ) ?? AnyView(EmptyView())
    }
}
