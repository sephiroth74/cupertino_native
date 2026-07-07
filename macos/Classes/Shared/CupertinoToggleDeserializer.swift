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
    var isDark: Bool?
    var labelChildren: [CNToggleChildPayload]
    var toggleStyle: String?
    var value: Bool?
    var viewModifiers: CNViewModifiersPayload

    init() {
        value = false
        labelChildren = []
        toggleStyle = "switch"
        isDark = nil
        viewModifiers = CNViewModifiersPayload()
    }

    init?(channel: [String: Any]) {
        self.init()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        viewModifiers.applyPatch(channel)

        if channel.keys.contains("value") {
            value = Self.decodeBool(channel["value"])
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
    }

    private static func decodeBool(_ value: Any?) -> Bool? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.boolValue ?? value as? Bool
    }

    private static func decodeString(_ value: Any?) -> String? {
        if value is NSNull { return nil }
        return value as? String
    }

    func toChannel() -> [String: Any] {
        var result = viewModifiers.toChannel()
        result.merge([
            "value": value as Any,
            "labelChildren": CNChannelSerialization.encodeArray(labelChildren),
            "toggleStyle": toggleStyle as Any,
            "isDark": isDark as Any,
        ]) { _, new in new }
        return result
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

            view = CNViewModifiers.apply(payload.viewModifiers, to: view)

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

            view = CNViewModifiers.apply(payload.viewModifiers, to: view)

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
        let valueKey = payload.value.map { String($0) } ?? "nil"
        let darkKey = payload.isDark.map { String($0) } ?? "nil"
        let modifiersKey = payload.viewModifiers.identityKey()

        return [
            childrenKey,
            styleKey,
            valueKey,
            darkKey,
            modifiersKey,
        ].joined(separator: "|")
    }
}
