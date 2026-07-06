import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoLabelNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>
    private let model: CNLabelViewModel

    private var payload: CNLabelPayload

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativeLabel_\(viewId)", binaryMessenger: messenger)
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))

        payload = CNChannelSerialization.decode(args) ?? Self.defaultPayload()
        model = CNLabelViewModel(payload: payload)

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
        NSLog("[CNLabel][Swift] Root view installed for viewId=\(viewId)")

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }

            switch call.method {
            case "getIntrinsicSize":
                let size = hostingView.fittingSize
                NSLog("[CNLabel][Swift] getIntrinsicSize -> width=\(size.width), height=\(size.height)")
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setData":
                if let raw = CNChannelSerialization.asDict(call.arguments) {
                    NSLog("[CNLabel][Swift] setData received full payload keys=\(Array(raw.keys))")
                    guard let decoded = CNLabelPayload(channel: raw) else {
                        result(FlutterError(code: "bad_args", message: "Missing label payload", details: nil))
                        return
                    }

                    payload = decoded
                    model.replace(with: decoded)
                    NSLog("[CNLabel][Swift] setData applied (full model replace)")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing label payload", details: nil))
                }
            case "applyPatch":
                if let patch = CNChannelSerialization.asDict(call.arguments) {
                    NSLog("[CNLabel][Swift] applyPatch received keys=\(Array(patch.keys))")
                    model.applyPatch(patch)
                    NSLog("[CNLabel][Swift] applyPatch applied")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing label patch payload", details: nil))
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

    private static func defaultPayload() -> CNLabelPayload {
        CNLabelPayload(channel: [
            "nodes": [
                "primaryText": ["text": ""],
            ],
        ])!
    }

    private func installRootView() {
        hostingView.rootView = CNLabel.deserialize(model: model) { [weak self] size in
            NSLog("[CNLabel][Swift] intrinsicSizeChanged -> width=\(size.width), height=\(size.height)")
            self?.channel.invokeMethod(
                "intrinsicSizeChanged",
                arguments: ["width": size.width, "height": size.height],
            )
        }
    }
}
