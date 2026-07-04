import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoSliderNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>

    private var payload: CNSliderPayload?

    private func sameSliderConfiguration(_ lhs: CNSliderPayload, _ rhs: CNSliderPayload) -> Bool {
        lhs.min == rhs.min &&
            lhs.max == rhs.max &&
            lhs.step == rhs.step &&
            lhs.isDark == rhs.isDark &&
            lhs.isEnabled == rhs.isEnabled &&
            lhs.controlSize == rhs.controlSize &&
            lhs.tint == rhs.tint &&
            lhs.width == rhs.width &&
            lhs.height == rhs.height
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativeSlider_\(viewId)", binaryMessenger: messenger)
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
            case "setSlider":
                if let raw = CNChannelSerialization.asDict(call.arguments) {
                    if let parsed = CNSliderPayload(channel: raw) {
                        if let current = payload, sameSliderConfiguration(current, parsed) {
                            // Value-only updates should not recreate the control while dragging.
                            payload = parsed
                            result(nil)
                            return
                        }

                        payload = parsed
                        rebuild()
                        result(nil)
                    } else {
                        result(FlutterError(code: "bad_args", message: "Invalid slider payload", details: nil))
                    }
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing slider payload", details: nil))
                }
            case "setValue":
                if let args = CNChannelSerialization.asDict(call.arguments),
                   let value = (args["value"] as? NSNumber)?.doubleValue,
                   var current = payload
                {
                    let clamped = Swift.min(Swift.max(value, current.min), current.max)
                    current = CNSliderPayload(channel: [
                        "value": clamped,
                        "min": current.min,
                        "max": current.max,
                        "step": current.step as Any,
                        "isDark": current.isDark as Any,
                        "isEnabled": current.isEnabled as Any,
                        "controlSize": current.controlSize as Any,
                        "tint": current.tint as Any,
                        "width": current.width as Any,
                        "height": current.height as Any,
                    ]) ?? current
                    payload = current
                    rebuild()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setRange":
                if let args = CNChannelSerialization.asDict(call.arguments),
                   let minValue = (args["min"] as? NSNumber)?.doubleValue,
                   let maxValue = (args["max"] as? NSNumber)?.doubleValue,
                   minValue < maxValue,
                   let current = payload
                {
                    let clampedValue = Swift.min(Swift.max(current.value, minValue), maxValue)
                    payload = CNSliderPayload(channel: [
                        "value": clampedValue,
                        "min": minValue,
                        "max": maxValue,
                        "step": current.step as Any,
                        "isDark": current.isDark as Any,
                        "isEnabled": current.isEnabled as Any,
                        "controlSize": current.controlSize as Any,
                        "tint": current.tint as Any,
                        "width": current.width as Any,
                        "height": current.height as Any,
                    ])
                    rebuild()
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

        hostingView.rootView = CNSlider.deserialize(
            payload.toChannel(),
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
        ) ?? AnyView(EmptyView())
    }
}
