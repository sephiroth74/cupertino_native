import SwiftUI

struct CNButtonChildPayload: CNChannelSerializable {
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

struct CNButtonPayload: CNChannelSerializable {
    var buttonChildren: [CNButtonChildPayload]
    var buttonRole: String?
    var buttonStyle: String?
    var isDark: Bool?
    var viewModifiers: CNViewModifiersPayload

    init() {
        buttonChildren = []
        buttonRole = nil
        buttonStyle = nil
        isDark = nil
        viewModifiers = CNViewModifiersPayload()
    }

    init?(channel: [String: Any]) {
        self.init()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        viewModifiers.applyPatch(channel)

        if channel.keys.contains("buttonChildren") {
            buttonChildren = CNChannelSerialization.decodeArray(channel["buttonChildren"])
        }

        if channel.keys.contains("buttonRole") {
            buttonRole = Self.decodeString(channel["buttonRole"])
        }

        if channel.keys.contains("buttonStyle") {
            buttonStyle = Self.decodeString(channel["buttonStyle"])
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
        result["buttonChildren"] = CNChannelSerialization.encodeArray(buttonChildren)
        result["buttonRole"] = buttonRole
        result["buttonStyle"] = buttonStyle
        result["isDark"] = isDark
        return result
    }
}

final class CNButtonViewModel: ObservableObject {
    @Published private(set) var payload: CNButtonPayload

    init(payload: CNButtonPayload) {
        self.payload = payload
    }

    func replace(with payload: CNButtonPayload) {
        self.payload = payload
    }

    func applyPatch(_ patch: [String: Any]) {
        var next = payload
        next.applyPatch(patch)
        payload = next
    }
}

enum CNButton {
    static func decode(_ raw: Any?) -> CNButtonPayload? {
        CNChannelSerialization.decode(raw)
    }

    static func deserialize(
        _ raw: Any?,
        onPressed: (() -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload: CNButtonPayload = CNChannelSerialization.decode(raw) else {
            return nil
        }

        return view(from: payload, onPressed: onPressed, onSizeChanged: onSizeChanged)
    }

    static func deserialize(
        _ dict: [String: Any],
        onPressed: (() -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload = CNButtonPayload(channel: dict) else {
            return nil
        }

        return view(from: payload, onPressed: onPressed, onSizeChanged: onSizeChanged)
    }

    static func deserialize(
        model: CNButtonViewModel,
        onPressed: (() -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundButtonView(model: model, onPressed: onPressed, onSizeChanged: onSizeChanged))
    }

    private static func view(
        from payload: CNButtonPayload,
        onPressed: (() -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        let enabled = payload.viewModifiers.enabled ?? true

        let tapAction = {
            guard enabled else { return }
            onPressed?()
        }

        let children = payload.buttonChildren.compactMap(deserializeChild)
        let role = buttonRole(from: payload.buttonRole)

        var button = AnyView(
            Button(role: role, action: tapAction) {
                buttonLabel(from: children)
            },
        )

        button = AnyView(button.disabled(!enabled))
        button = applyButtonStyle(to: button, buttonStyle: payload.buttonStyle)
        button = CNViewModifiers.apply(payload.viewModifiers, to: button)

        if let onSizeChanged {
            button = AnyView(
                button.onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newSize in
                    onSizeChanged(newSize)
                },
            )
        }

        return AnyView(button.id(identityKey(for: payload)))
    }

    private struct _CNBoundButtonView: View {
        @ObservedObject var model: CNButtonViewModel
        let onPressed: (() -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload
            let enabled = payload.viewModifiers.enabled ?? true

            let tapAction = {
                guard enabled else { return }
                onPressed?()
            }

            let children = payload.buttonChildren.compactMap(deserializeChild)
            let role = buttonRole(from: payload.buttonRole)

            var button = AnyView(
                Button(role: role, action: tapAction) {
                    buttonLabel(from: children)
                },
            )

            button = AnyView(button.disabled(!enabled))
            button = applyButtonStyle(to: button, buttonStyle: payload.buttonStyle)
            button = CNViewModifiers.apply(payload.viewModifiers, to: button)

            if let onSizeChanged {
                button = AnyView(
                    button.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newSize in
                        onSizeChanged(newSize)
                    },
                )
            }

            return AnyView(button.id(identityKey(for: payload)))
        }
    }

    private static func deserializeChild(_ child: CNButtonChildPayload) -> AnyView? {
        switch child.type {
        case "image":
            return CNImage.deserialize(child.payload)
        case "label":
            return CNLabel.deserialize(child.payload)
        case "text":
            return CNText.deserialize(child.payload)
        case "progressView":
            return CNProgressViewDeserializer.deserialize(child.payload)
        default:
            NSLog("Unknown button child type: \(child.type)")
            return nil
        }
    }

    private static func buttonLabel(from children: [AnyView]) -> AnyView {
        if children.isEmpty {
            return AnyView(EmptyView())
        }

        if children.count == 1 {
            return children[0]
        }

        return AnyView(
            Group {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    child
                }
            },
        )
    }

    private static func buttonRole(from role: String?) -> ButtonRole? {
        switch role {
        case "cancel":
            .cancel
        case "destructive":
            .destructive
        case "confirm":
            .confirm
        case "close":
            .close
        default:
            nil
        }
    }

    private static func applyButtonStyle(to view: AnyView, buttonStyle: String?) -> AnyView {
        switch buttonStyle {
        case "bordered":
            AnyView(view.buttonStyle(BorderedButtonStyle()))
        case "borderedProminent":
            AnyView(view.buttonStyle(BorderedProminentButtonStyle()))
        case "borderless":
            AnyView(view.buttonStyle(BorderlessButtonStyle()))
        case "plain":
            AnyView(view.buttonStyle(PlainButtonStyle()))
        case "glass":
            AnyView(view.buttonStyle(GlassButtonStyle()))
        case "glassProminent", "prominentGlass":
            AnyView(view.buttonStyle(GlassProminentButtonStyle()))
        case "link":
            AnyView(view.buttonStyle(LinkButtonStyle()))
        case "accessoryBar":
            AnyView(view.buttonStyle(AccessoryBarButtonStyle()))
        case "accessoryBarAction":
            AnyView(view.buttonStyle(AccessoryBarActionButtonStyle()))
        default:
            AnyView(view.buttonStyle(DefaultButtonStyle()))
        }
    }

    private static func identityKey(for payload: CNButtonPayload) -> String {
        let childrenKey = payload.buttonChildren.map { String(describing: $0.toChannel()) }.joined(separator: ";")
        let roleKey = payload.buttonRole ?? "nil"
        let styleKey = payload.buttonStyle ?? "nil"
        let controlSizeKey = payload.viewModifiers.controlSize ?? "nil"
        let enabledKey = payload.viewModifiers.enabled.map { String($0) } ?? "nil"
        let tintKey = payload.viewModifiers.tint.map { String($0) } ?? "nil"
        let widthKey = payload.viewModifiers.width.map { String($0) } ?? "nil"
        let heightKey = payload.viewModifiers.height.map { String($0) } ?? "nil"
        let foregroundColorKey = payload.viewModifiers.foregroundColor.map { String($0) } ?? "nil"
        let darkKey = payload.isDark.map { String($0) } ?? "nil"

        return [
            childrenKey,
            roleKey,
            styleKey,
            controlSizeKey,
            enabledKey,
            tintKey,
            widthKey,
            heightKey,
            darkKey,
            foregroundColorKey,
        ].joined(separator: "|")
    }
}
