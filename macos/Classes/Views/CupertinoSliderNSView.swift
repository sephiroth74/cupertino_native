import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoSliderNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>
    private let model: CNSliderViewModel

    private var payload: CNSliderPayload

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativeSlider_\(viewId)", binaryMessenger: messenger)
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))

        payload = CNChannelSerialization.decode(args) ?? Self.defaultPayload()
        model = CNSliderViewModel(payload: payload)

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
        updateAppearance()

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }

            switch call.method {
            case "getIntrinsicSize":
                let size = hostingView.fittingSize
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setData":
                if let raw = CNChannelSerialization.asDict(call.arguments) {
                    print("[CNSliderNSView] setData <- \(raw)")
                    if let parsed = CNSliderPayload(channel: raw) {
                        payload = parsed
                        model.replace(with: payload)
                        updateAppearance()
                        result(nil)
                    } else {
                        result(FlutterError(code: "bad_args", message: "Invalid slider payload", details: nil))
                    }
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing slider payload", details: nil))
                }
            case "applyPatch":
                if let patch = CNChannelSerialization.asDict(call.arguments) {
                    print("[CNSliderNSView] applyPatch <- \(patch)")
                    payload.applyPatch(patch)
                    model.replace(with: payload)
                    updateAppearance()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing slider patch payload", details: nil))
                }
            case "setValue":
                if let args = CNChannelSerialization.asDict(call.arguments),
                   let value = (args["value"] as? NSNumber)?.doubleValue,
                   payload.min < payload.max
                {
                    print("[CNSliderNSView] setValue <- \(value)")
                    payload.applyPatch(["value": value])
                    model.replace(with: payload)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setRange":
                if let args = CNChannelSerialization.asDict(call.arguments),
                   let minValue = (args["min"] as? NSNumber)?.doubleValue,
                   let maxValue = (args["max"] as? NSNumber)?.doubleValue,
                   minValue < maxValue,
                   payload.min < payload.max
                {
                    print("[CNSliderNSView] setRange <- min=\(minValue), max=\(maxValue)")
                    payload.applyPatch(["min": minValue, "max": maxValue])
                    model.replace(with: payload)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing min/max", details: nil))
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

    private static func defaultPayload() -> CNSliderPayload {
        CNSliderPayload(channel: [
            "value": 0.0,
            "min": 0.0,
            "max": 1.0,
        ])!
    }

    private func installRootView() {
        hostingView.rootView = CNSlider.deserialize(
            model: model,
            onValueChanged: { [weak self] newValue in
                self?.channel.invokeMethod("valueChanged", arguments: ["value": newValue])
            },
            onEditingChanged: { [weak self] editing in
                self?.channel.invokeMethod("editingChanged", arguments: ["editing": editing])
            },
            onSizeChanged: { [weak self] size in
                self?.channel.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": size.width, "height": size.height],
                )
            },
        )
    }

    private func updateAppearance() {
        if let isDark = payload.isDark {
            hostingView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        } else {
            hostingView.appearance = nil
        }
    }
}
