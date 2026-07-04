import SwiftUI

private final class CNSliderValueBox {
    init(_ value: Double) {
        self.value = value
    }

    var value: Double
}

struct CNSliderPayload: CNChannelSerializable {
    let controlSize: String?
    let height: Double?
    let isDark: Bool?
    let isEnabled: Bool?
    let max: Double
    let min: Double
    let step: Double?
    let tint: Int?
    let value: Double
    let width: Double?

    init?(channel: [String: Any]) {
        guard let rawValue = (channel["value"] as? NSNumber)?.doubleValue ?? channel["value"] as? Double,
              let rawMin = (channel["min"] as? NSNumber)?.doubleValue ?? channel["min"] as? Double,
              let rawMax = (channel["max"] as? NSNumber)?.doubleValue ?? channel["max"] as? Double,
              rawMin < rawMax
        else {
            return nil
        }

        value = Swift.min(Swift.max(rawValue, rawMin), rawMax)
        min = rawMin
        max = rawMax
        step = (channel["step"] as? NSNumber)?.doubleValue ?? channel["step"] as? Double
        isDark = (channel["isDark"] as? NSNumber)?.boolValue ?? channel["isDark"] as? Bool
        isEnabled = (channel["isEnabled"] as? NSNumber)?.boolValue ?? channel["isEnabled"] as? Bool
        controlSize = channel["controlSize"] as? String
        tint = (channel["tint"] as? NSNumber)?.intValue ?? channel["tint"] as? Int
        width = (channel["width"] as? NSNumber)?.doubleValue ?? channel["width"] as? Double
        height = (channel["height"] as? NSNumber)?.doubleValue ?? channel["height"] as? Double
    }

    func toChannel() -> [String: Any] {
        [
            "value": value,
            "min": min,
            "max": max,
            "step": step as Any,
            "isDark": isDark as Any,
            "isEnabled": isEnabled as Any,
            "controlSize": controlSize as Any,
            "tint": tint as Any,
            "width": width as Any,
            "height": height as Any,
        ]
    }
}

enum CNSlider {
    static func deserialize(
        _ raw: Any?,
        onValueChanged: ((Double) -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload: CNSliderPayload = CNChannelSerialization.decode(raw) else {
            return nil
        }

        return view(
            from: payload,
            onValueChanged: onValueChanged,
            onEditingChanged: onEditingChanged,
            onSizeChanged: onSizeChanged,
        )
    }

    static func deserialize(
        _ dict: [String: Any],
        onValueChanged: ((Double) -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload = CNSliderPayload(channel: dict) else {
            return nil
        }

        return view(
            from: payload,
            onValueChanged: onValueChanged,
            onEditingChanged: onEditingChanged,
            onSizeChanged: onSizeChanged,
        )
    }

    private static func view(
        from payload: CNSliderPayload,
        onValueChanged: ((Double) -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        let valueBox = CNSliderValueBox(payload.value)

        let valueBinding = Binding<Double>(
            get: { valueBox.value },
            set: { newValue in
                valueBox.value = newValue
                onValueChanged?(newValue)
            },
        )

        var sliderView = if let step = payload.step, step > 0 {
            AnyView(
                Slider(
                    value: valueBinding,
                    in: payload.min ... payload.max,
                    step: step,
                    onEditingChanged: { editing in
                        onEditingChanged?(editing)
                    },
                ),
            )
        } else {
            AnyView(
                Slider(
                    value: valueBinding,
                    in: payload.min ... payload.max,
                    onEditingChanged: { editing in
                        onEditingChanged?(editing)
                    },
                ),
            )
        }

        if let tint = payload.tint {
            sliderView = AnyView(sliderView.tint(ColorUtils.swiftUIColorFromARGB(tint)))
        }

        if let isEnabled = payload.isEnabled {
            sliderView = AnyView(sliderView.disabled(!isEnabled))
        }

        if let width = payload.width, let height = payload.height {
            sliderView = AnyView(sliderView.frame(width: CGFloat(width), height: CGFloat(height)))
        } else if let width = payload.width {
            sliderView = AnyView(sliderView.frame(width: CGFloat(width)))
        } else if let height = payload.height {
            sliderView = AnyView(sliderView.frame(height: CGFloat(height)))
        }

        sliderView = applyControlSize(to: sliderView, controlSize: payload.controlSize)

        if let onSizeChanged {
            sliderView = AnyView(
                sliderView.onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newSize in
                    onSizeChanged(newSize)
                },
            )
        }

        let identifier = identityKey(for: payload)
        return AnyView(sliderView.id(identifier))
    }

    private static func applyControlSize(to view: AnyView, controlSize: String?) -> AnyView {
        switch controlSize {
        case "mini":
            AnyView(view.controlSize(.mini))
        case "small":
            AnyView(view.controlSize(.small))
        case "regular":
            AnyView(view.controlSize(.regular))
        case "large":
            AnyView(view.controlSize(.large))
        case "extraLarge":
            if #available(macOS 14.0, *) {
                AnyView(view.controlSize(.extraLarge))
            } else {
                AnyView(view.controlSize(.large))
            }
        default:
            view
        }
    }

    private static func identityKey(for payload: CNSliderPayload) -> String {
        let stepKey = if let step = payload.step { "\(step)" } else { "nil" }
        let isDarkKey = if let isDark = payload.isDark { "\(isDark)" } else { "nil" }
        let enabledKey = if let isEnabled = payload.isEnabled { "\(isEnabled)" } else { "nil" }
        let tintKey = if let tint = payload.tint { "\(tint)" } else { "nil" }
        let widthKey = if let width = payload.width { "\(width)" } else { "nil" }
        let heightKey = if let height = payload.height { "\(height)" } else { "nil" }

        return [
            "\(payload.value)",
            "\(payload.min)",
            "\(payload.max)",
            stepKey,
            payload.controlSize ?? "nil",
            isDarkKey,
            enabledKey,
            tintKey,
            widthKey,
            heightKey,
        ].joined(separator: "|")
    }
}
