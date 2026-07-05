import SwiftUI

struct CNToggleChildPayload: CNChannelSerializable {
    let payload: [String: Any]
    let type: String

    init?(channel: [String: Any]) {
        guard let type = channel["type"] as? String,
              let payload = channel["payload"] as? [String: Any]
        else {
            return nil
        }

        self.type = type
        self.payload = payload
    }

    func toChannel() -> [String: Any] {
        [
            "type": type,
            "payload": payload,
        ]
    }
}

struct CNTogglePayload: CNChannelSerializable {
    var controlSize: String?
    var enabled: Bool?
    var foregroundColor: Int?
    var height: Double?
    var isDark: Bool?
    var labelChildren: [CNToggleChildPayload]
    var tint: Int?
    var toggleStyle: String?
    var value: Bool?
    var width: Double?

    init() {
        value = false
        enabled = true
        labelChildren = []
        toggleStyle = "switch"
        isDark = nil
        controlSize = "regular"
        tint = nil
        foregroundColor = nil
        width = nil
        height = nil
    }

    init?(channel: [String: Any]) {
        self.init()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        if channel.keys.contains("value") {
            value = Self.decodeBool(channel["value"])
        }

        if channel.keys.contains("enabled") {
            enabled = Self.decodeBool(channel["enabled"])
        }

        if channel.keys.contains("labelChildren") {
            labelChildren = CNChannelSerialization.decodeArray(channel["labelChildren"])
        }

        if channel.keys.contains("toggleStyle") {
            toggleStyle = Self.decodeString(channel["toggleStyle"])
        }

        if channel.keys.contains("isDark") {
            isDark = Self.decodeBool(channel["isDark"])
        }

        if channel.keys.contains("controlSize") {
            controlSize = Self.decodeString(channel["controlSize"])
        }

        if channel.keys.contains("tint") {
            tint = Self.decodeInt(channel["tint"])
        }

        if channel.keys.contains("foregroundColor") {
            foregroundColor = Self.decodeInt(channel["foregroundColor"])
        }

        if channel.keys.contains("width") {
            width = Self.decodeDouble(channel["width"])
        }

        if channel.keys.contains("height") {
            height = Self.decodeDouble(channel["height"])
        }
    }

    private static func decodeBool(_ value: Any?) -> Bool? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.boolValue ?? value as? Bool
    }

    private static func decodeInt(_ value: Any?) -> Int? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.intValue ?? value as? Int
    }

    private static func decodeDouble(_ value: Any?) -> Double? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.doubleValue ?? value as? Double
    }

    private static func decodeString(_ value: Any?) -> String? {
        if value is NSNull { return nil }
        return value as? String
    }

    func toChannel() -> [String: Any] {
        [
            "value": value as Any,
            "enabled": enabled as Any,
            "labelChildren": CNChannelSerialization.encodeArray(labelChildren),
            "toggleStyle": toggleStyle as Any,
            "isDark": isDark as Any,
            "controlSize": controlSize as Any,
            "tint": tint as Any,
            "foregroundColor": foregroundColor as Any,
            "width": width as Any,
            "height": height as Any,
        ]
    }
}

final class CNToggleViewModel: ObservableObject {
    @Published private(set) var payload: CNTogglePayload

    init(payload: CNTogglePayload) {
        self.payload = payload
    }

    func replace(with payload: CNTogglePayload) {
        self.payload = payload
    }

    func update(_ mutate: (inout CNTogglePayload) -> Void) {
        var next = payload
        mutate(&next)
        payload = next
    }
}

enum CNToggleDeserializer {
    static func decode(_ raw: Any?) -> CNTogglePayload? {
        CNChannelSerialization.decode(raw)
    }

    static func deserialize(
        _ raw: Any?,
        onChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload: CNTogglePayload = CNChannelSerialization.decode(raw) else {
            return nil
        }

        return view(from: payload, onChanged: onChanged, onSizeChanged: onSizeChanged)
    }

    static func deserialize(
        _ dict: [String: Any],
        onChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload = CNTogglePayload(channel: dict) else {
            return nil
        }

        return view(from: payload, onChanged: onChanged, onSizeChanged: onSizeChanged)
    }

    static func deserialize(
        model: CNToggleViewModel,
        onChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(
            _CNBoundToggleView(model: model, onChanged: onChanged, onSizeChanged: onSizeChanged),
        )
    }

    private static func view(
        from payload: CNTogglePayload,
        onChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(
            _CNToggleView(payload: payload, onChanged: onChanged, onSizeChanged: onSizeChanged)
                .id(identityKey(for: payload)),
        )
    }

    private static func deserializeLabelChild(_ child: CNToggleChildPayload) -> AnyView {
        switch child.type {
        case "image":
            CNImage.deserialize(child.payload) ?? AnyView(EmptyView())
        case "label":
            CNLabel.deserialize(child.payload) ?? AnyView(EmptyView())
        case "text":
            CNText.deserialize(child.payload) ?? AnyView(EmptyView())
        case "progressView":
            CNProgressViewDeserializer.deserialize(child.payload) ?? AnyView(EmptyView())
        default:
            AnyView(EmptyView())
        }
    }

    private struct _CNToggleView: View {
        let payload: CNTogglePayload
        let onChanged: ((Bool) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?

        @State private var isOn: Bool

        init(
            payload: CNTogglePayload,
            onChanged: ((Bool) -> Void)? = nil,
            onSizeChanged: ((CGSize) -> Void)? = nil,
        ) {
            self.payload = payload
            self.onChanged = onChanged
            self.onSizeChanged = onSizeChanged
            _isOn = State(initialValue: payload.value ?? false)
        }

        var body: some View {
            var view = AnyView(
                Toggle(
                    isOn: Binding(
                        get: { isOn },
                        set: { newValue in
                            isOn = newValue
                            onChanged?(newValue)
                        },
                    ),
                ) {
                    if payload.labelChildren.isEmpty {
                        EmptyView()
                    } else if payload.labelChildren.count == 1 {
                        CNToggleDeserializer.deserializeLabelChild(payload.labelChildren[0])
                    } else {
                        ForEach(Array(payload.labelChildren.enumerated()), id: \.offset) { _, child in
                            CNToggleDeserializer.deserializeLabelChild(child)
                        }
                    }
                },
            )

            view = AnyView(view.disabled(!(payload.enabled ?? true)))
            view = AnyView(view.controlSize(SwiftUtils.controlSizeFromString(payload.controlSize)))

            if let tint = payload.tint {
                view = AnyView(view.tint(ColorUtils.swiftUIColorFromARGB(tint)))
            }

            if let foregroundColor = payload.foregroundColor {
                view = AnyView(view.foregroundStyle(ColorUtils.swiftUIColorFromARGB(foregroundColor)))
            }

            if let width = payload.width, let height = payload.height {
                view = AnyView(view.frame(width: CGFloat(width), height: CGFloat(height)))
            } else if let width = payload.width {
                view = AnyView(view.frame(width: CGFloat(width)))
            } else if let height = payload.height {
                view = AnyView(view.frame(height: CGFloat(height)))
            }

            switch payload.toggleStyle {
            case "automatic":
                view = AnyView(view.toggleStyle(.automatic))
            case "checkbox":
                view = AnyView(view.toggleStyle(.checkbox))
            case "button":
                view = AnyView(view.toggleStyle(.button))
            case "switch":
                view = AnyView(view.toggleStyle(.switch))
            default:
                view = AnyView(view.toggleStyle(.automatic))
            }

            if let onSizeChanged {
                view = AnyView(
                    view.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { size in
                        onSizeChanged(size)
                    },
                )
            }

            return view
        }
    }

    private struct _CNBoundToggleView: View {
        @ObservedObject var model: CNToggleViewModel
        let onChanged: ((Bool) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            var view = AnyView(
                Toggle(
                    isOn: Binding(
                        get: { model.payload.value ?? false },
                        set: { newValue in
                            guard model.payload.value != newValue else {
                                return
                            }

                            model.update { next in
                                next.value = newValue
                            }
                            onChanged?(newValue)
                        },
                    ),
                ) {
                    if payload.labelChildren.isEmpty {
                        EmptyView()
                    } else if payload.labelChildren.count == 1 {
                        CNToggleDeserializer.deserializeLabelChild(payload.labelChildren[0])
                    } else {
                        ForEach(Array(payload.labelChildren.enumerated()), id: \.offset) { _, child in
                            CNToggleDeserializer.deserializeLabelChild(child)
                        }
                    }
                },
            )

            view = AnyView(view.disabled(!(payload.enabled ?? true)))
            view = AnyView(view.controlSize(SwiftUtils.controlSizeFromString(payload.controlSize)))

            if let tint = payload.tint {
                view = AnyView(view.tint(ColorUtils.swiftUIColorFromARGB(tint)))
            }

            if let foregroundColor = payload.foregroundColor {
                view = AnyView(view.foregroundStyle(ColorUtils.swiftUIColorFromARGB(foregroundColor)))
            }

            if let width = payload.width, let height = payload.height {
                view = AnyView(view.frame(width: CGFloat(width), height: CGFloat(height)))
            } else if let width = payload.width {
                view = AnyView(view.frame(width: CGFloat(width)))
            } else if let height = payload.height {
                view = AnyView(view.frame(height: CGFloat(height)))
            }

            switch payload.toggleStyle {
            case "automatic":
                view = AnyView(view.toggleStyle(.automatic))
            case "checkbox":
                view = AnyView(view.toggleStyle(.checkbox))
            case "button":
                view = AnyView(view.toggleStyle(.button))
            case "switch":
                view = AnyView(view.toggleStyle(.switch))
            default:
                view = AnyView(view.toggleStyle(.automatic))
            }

            if let onSizeChanged {
                view = AnyView(
                    view.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { size in
                        onSizeChanged(size)
                    },
                )
            }

            return view
        }
    }

    private static func identityKey(for payload: CNTogglePayload) -> String {
        let childrenKey = payload.labelChildren.map { String(describing: $0.toChannel()) }.joined(separator: ";")
        let styleKey = payload.toggleStyle ?? "nil"
        let controlSizeKey = payload.controlSize ?? "nil"
        let enabledKey = payload.enabled.map { String($0) } ?? "nil"
        let valueKey = payload.value.map { String($0) } ?? "nil"
        let tintKey = payload.tint.map { String($0) } ?? "nil"
        let foregroundKey = payload.foregroundColor.map { String($0) } ?? "nil"
        let widthKey = payload.width.map { String($0) } ?? "nil"
        let heightKey = payload.height.map { String($0) } ?? "nil"
        let darkKey = payload.isDark.map { String($0) } ?? "nil"

        return [
            childrenKey,
            styleKey,
            controlSizeKey,
            enabledKey,
            valueKey,
            tintKey,
            foregroundKey,
            widthKey,
            heightKey,
            darkKey,
        ].joined(separator: "|")
    }
}
