import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoImageView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>
    private let model: CNImageViewModel

    private var payload: CNImagePayload

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativeImage_\(viewId)", binaryMessenger: messenger)
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))

        payload = CNChannelSerialization.decode(args) ?? Self.defaultPayload()
        model = CNImageViewModel(payload: payload)

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

        installRootView()
        // NSLog("[CNImage][Swift] Root view installed for viewId=\(viewId)")

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { result(nil); return }
            switch call.method {
            case "setData":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    // NSLog("[CNImage][Swift] setImage received full payload keys=\(Array(args.keys))")
                    guard let decoded = CNImagePayload(channel: args) else {
                        result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                        return
                    }
                    payload = decoded
                    model.replace(with: payload)
                    // NSLog("[CNImage][Swift] setImage applied (full model replace)")
                    result(nil)
                } else { result(FlutterError(code: "bad_args", message: "Missing args", details: nil)) }
            case "applyPatch":
                if let patch = CNChannelSerialization.asDict(call.arguments) {
                    // NSLog("[CNImage][Swift] applyPatch received keys=\(Array(patch.keys))")
                    payload.applyPatch(patch)
                    model.replace(with: payload)
                    // NSLog("[CNImage][Swift] applyPatch applied")
                    result(nil)
                } else { result(FlutterError(code: "bad_args", message: "Missing patch args", details: nil)) }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder _: NSCoder) {
        nil
    }

    private static func defaultPayload() -> CNImagePayload {
        CNImagePayload(channel: ["systemSymbolName": "questionmark.circle"])!
    }

    private func installRootView() {
        hostingView.rootView = CNImage.deserialize(
            model: model,
            onSizeChanged: { [weak self] size in
                self?.channel.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": size.width, "height": size.height],
                )
            },
        )
    }
}
