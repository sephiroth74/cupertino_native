import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoImage2NSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>
    private let model: CNImage2ViewModel
    private var payload: CNImage2Payload
    private var measuredSize: CGSize?

    private var logPrefix: String {
        let debugId = payload.viewDebugId
        return "[CNImage2][\(debugId)][Swift]"
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativeImage2_\(viewId)", binaryMessenger: messenger)
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))

        payload = CNChannelDeserialization.decode(args, viewId: viewId) ?? Self.defaultPayload(viewId)
        model = CNImage2ViewModel(payload: payload)

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

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { result(nil); return }
            switch call.method {
            case "setData":
                if let args = CNChannelDeserialization.asDict(call.arguments) {
                    NSLog("\(logPrefix) setData received full payload keys=\(Array(args.keys))")
                    guard let decoded = CNImage2Payload(channel: args, viewId: viewId) else {
                        result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                        return
                    }
                    payload = decoded
                    model.replace(with: payload)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                }
            case "applyPatch":
                if let patch = CNChannelDeserialization.asDict(call.arguments) {
                    NSLog("\(logPrefix) applyPatch received keys=\(Array(patch.keys))")
                    payload.applyPatch(patch)
                    model.replace(with: payload)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing patch args", details: nil))
                }
            default:
                NSLog("\(logPrefix) Unhandled method call: \(call.method)")
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder _: NSCoder) {
        nil
    }

    private static func defaultPayload(_ viewId: Int64) -> CNImage2Payload {
        CNImage2Payload(channel: ["systemSymbolName": "questionmark.circle"], viewId: viewId)!
    }

    private func installRootView() {
        hostingView.rootView = CNImage2Deserializer.deserialize(
            model: model,
            onSizeChanged: { [weak self] newSize in
                guard let self else { return }

                measuredSize = currentIntrinsicSize()
                NSLog("\(logPrefix) onSizeChange. newSize: \(newSize), currentSize: \(measuredSize!)")

                channel.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": measuredSize!.width, "height": measuredSize!.height],
                )
            },
        )
    }

    private func currentIntrinsicSize() -> CGSize {
        layoutSubtreeIfNeeded()
        hostingView.layoutSubtreeIfNeeded()

        let intrinsic = hostingView.intrinsicContentSize
        let fitting = hostingView.fittingSize

        let width = max(
            intrinsic.width == NSView.noIntrinsicMetric ? 0 : intrinsic.width,
            fitting.width,
        )
        let height = max(
            intrinsic.height == NSView.noIntrinsicMetric ? 0 : intrinsic.height,
            fitting.height,
        )

        return CGSize(width: width, height: height)
    }
}
