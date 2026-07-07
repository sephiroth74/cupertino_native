import SwiftUI

private final class CNSliderValueBox {
    init(_ value: Double) {
        self.value = value
    }

    var value: Double
}

struct CNSliderPayload: CNChannelSerializable {
    var isDark: Bool?
    var max: Double
    var min: Double
    var step: Double?
    var value: Double
    var viewModifiers: CNViewModifiersPayload

    init() {
        value = 0.0
        min = 0.0
        max = 1.0
        step = nil
        isDark = nil
        viewModifiers = CNViewModifiersPayload()
    }

    init?(channel: [String: Any]) {
        guard channel["value"] != nil,
              channel["min"] != nil,
              channel["max"] != nil
        else {
            return nil
        }

        self.init()
        applyPatch(channel)
        if min >= max {
            return nil
        }
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        viewModifiers.applyPatch(channel)

        // Legacy compatibility for older payloads before `enabled` moved to shared modifiers.
        if channel.keys.contains("isEnabled") {
            viewModifiers.enabled = Self.decodeBool(channel["isEnabled"])
        }

        if channel.keys.contains("min") {
            min = Self.decodeDouble(channel["min"]) ?? min
        }

        if channel.keys.contains("max") {
            max = Self.decodeDouble(channel["max"]) ?? max
        }

        if min >= max {
            let fallbackMax = min + 1.0
            max = fallbackMax
        }

        if channel.keys.contains("value") {
            if let rawValue = Self.decodeDouble(channel["value"]) {
                value = Swift.min(Swift.max(rawValue, min), max)
            }
        } else {
            value = Swift.min(Swift.max(value, min), max)
        }

        if channel.keys.contains("step") {
            step = Self.decodeDouble(channel["step"])
        }

        if channel.keys.contains("isDark") {
            isDark = Self.decodeBool(channel["isDark"])
        }
    }

    private static func decodeBool(_ value: Any?) -> Bool? {
        if value is NSNull {
            return nil
        }
        return (value as? NSNumber)?.boolValue ?? value as? Bool
    }

    private static func decodeDouble(_ value: Any?) -> Double? {
        if value is NSNull {
            return nil
        }
        return (value as? NSNumber)?.doubleValue ?? value as? Double
    }

    func toChannel() -> [String: Any] {
        var result = viewModifiers.toChannel()
        result["value"] = value
        result["min"] = min
        result["max"] = max
        result["step"] = step
        result["isDark"] = isDark
        return result
    }
}

final class CNSliderViewModel: ObservableObject {
    @Published private(set) var payload: CNSliderPayload

    init(payload: CNSliderPayload) {
        self.payload = payload
    }

    func replace(with payload: CNSliderPayload) {
        self.payload = payload
    }

    func applyPatch(_ patch: [String: Any]) {
        var next = payload
        next.applyPatch(patch)
        payload = next
    }

    func setValue(_ value: Double) {
        var next = payload
        next.applyPatch(["value": value])
        payload = next
    }

    func setRange(min: Double, max: Double) {
        var next = payload
        next.applyPatch(["min": min, "max": max])
        payload = next
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

    static func deserialize(
        model: CNSliderViewModel,
        onValueChanged: ((Double) -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(
            _CNBoundSliderView(
                model: model,
                onValueChanged: onValueChanged,
                onEditingChanged: onEditingChanged,
                onSizeChanged: onSizeChanged,
            ),
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

        sliderView = CNViewModifiers.apply(payload.viewModifiers, to: sliderView)

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

    private struct _CNBoundSliderView: View {
        @ObservedObject var model: CNSliderViewModel
        let onValueChanged: ((Double) -> Void)?
        let onEditingChanged: ((Bool) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            let valueBinding = Binding<Double>(
                get: { model.payload.value },
                set: { newValue in
                    model.setValue(newValue)
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

            sliderView = CNViewModifiers.apply(payload.viewModifiers, to: sliderView)

            if let onSizeChanged {
                sliderView = AnyView(
                    sliderView.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newSize in
                        onSizeChanged(newSize)
                    },
                )
            }

            return sliderView
        }
    }

    private static func identityKey(for payload: CNSliderPayload) -> String {
        let stepKey = if let step = payload.step {
            "\(step)"
        } else {
            "nil"
        }
        let isDarkKey = if let isDark = payload.isDark {
            "\(isDark)"
        } else {
            "nil"
        }
        let modifiersKey = payload.viewModifiers.identityKey()

        return [
            "\(payload.value)",
            "\(payload.min)",
            "\(payload.max)",
            stepKey,
            isDarkKey,
            modifiersKey,
        ].joined(separator: "|")
    }
}
