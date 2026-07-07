import SwiftUI

struct CNMenuChildPayload: CNChannelSerializable {
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

struct CNMenuPayload: CNChannelSerializable {
    var children: [CNMenuChildPayload]
    var isDark: Bool?
    var labelChildren: [CNButtonChildPayload]
    var menuStyle: String?
    var viewModifiers: CNViewModifiersPayload

    init?(channel: [String: Any]) {
        children = []
        labelChildren = []
        menuStyle = nil
        isDark = nil
        viewModifiers = CNViewModifiersPayload()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        if channel.keys.contains("children") {
            children = CNChannelSerialization.decodeArray(channel["children"])
        }

        if channel.keys.contains("labelChildren") {
            labelChildren = CNChannelSerialization.decodeArray(channel["labelChildren"])
        }

        if channel.keys.contains("menuStyle") {
            if channel["menuStyle"] is NSNull {
                menuStyle = nil
            } else {
                menuStyle = channel["menuStyle"] as? String
            }
        }

        if channel.keys.contains("isDark") {
            isDark = CNViewModifiersPayload.decodeBool(channel["isDark"])
        }

        viewModifiers.applyPatch(channel)
    }

    func toChannel() -> [String: Any] {
        var channel = viewModifiers.toChannel()
        channel.merge([
            "children": CNChannelSerialization.encodeArray(children),
            "labelChildren": CNChannelSerialization.encodeArray(labelChildren),
            "menuStyle": menuStyle as Any,
            "isDark": isDark as Any,
        ]) { _, new in new }

        return channel
    }
}

enum CNMenuDeserializer {
    static func decode(_ raw: Any?) -> CNMenuPayload? {
        CNChannelSerialization.decode(raw)
    }

    static func deserialize(
        _ raw: Any?,
        onPrimaryAction: (() -> Void)? = nil,
        onMenuButtonPressed: ((Int) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload: CNMenuPayload = CNChannelSerialization.decode(raw) else {
            return nil
        }

        return view(
            from: payload,
            onPrimaryAction: onPrimaryAction,
            onMenuButtonPressed: onMenuButtonPressed,
            onSizeChanged: onSizeChanged,
        )
    }

    static func deserialize(
        _ dict: [String: Any],
        onPrimaryAction: (() -> Void)? = nil,
        onMenuButtonPressed: ((Int) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload = CNMenuPayload(channel: dict) else {
            return nil
        }

        return view(
            from: payload,
            onPrimaryAction: onPrimaryAction,
            onMenuButtonPressed: onMenuButtonPressed,
            onSizeChanged: onSizeChanged,
        )
    }

    private static func view(
        from payload: CNMenuPayload,
        onPrimaryAction: (() -> Void)? = nil,
        onMenuButtonPressed: ((Int) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        var menu = baseMenu(from: payload, onPrimaryAction: onPrimaryAction, onMenuButtonPressed: onMenuButtonPressed)

        menu = applyMenuStyle(to: menu, style: payload.menuStyle)
        menu = CNViewModifiers.apply(payload.viewModifiers, to: menu)

        if let onSizeChanged {
            menu = AnyView(
                menu.onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newSize in
                    onSizeChanged(newSize)
                },
            )
        }

        return AnyView(menu.id(identityKey(for: payload)))
    }

    private static func baseMenu(
        from payload: CNMenuPayload,
        onPrimaryAction: (() -> Void)? = nil,
        onMenuButtonPressed: ((Int) -> Void)? = nil,
    ) -> AnyView {
        if let onPrimaryAction {
            return AnyView(
                Menu {
                    menuChildren(from: payload.children, onMenuButtonPressed: onMenuButtonPressed)
                } label: {
                    labelChildren(from: payload.labelChildren)
                } primaryAction: {
                    onPrimaryAction()
                },
            )
        }

        return AnyView(
            Menu {
                menuChildren(from: payload.children, onMenuButtonPressed: onMenuButtonPressed)
            } label: {
                labelChildren(from: payload.labelChildren)
            },
        )
    }

    @ViewBuilder
    private static func labelChildren(from children: [CNButtonChildPayload]) -> some View {
        if children.isEmpty {
            Text("Menu")
        } else if children.count == 1 {
            deserializeButtonLabelChild(children[0])
        } else {
            ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                deserializeButtonLabelChild(child)
            }
        }
    }

    private static func menuChildren(
        from children: [CNMenuChildPayload],
        onMenuButtonPressed: ((Int) -> Void)? = nil,
    ) -> some View {
        ForEach(Array(children.enumerated()), id: \.offset) { _, child in
            deserializeMenuChild(child, onMenuButtonPressed: onMenuButtonPressed)
        }
    }

    private static func deserializeButtonLabelChild(_ child: CNButtonChildPayload) -> AnyView {
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

    private static func deserializeMenuChild(
        _ child: CNMenuChildPayload,
        onMenuButtonPressed: ((Int) -> Void)? = nil,
    ) -> AnyView {
        switch child.type {
        case "button":
            deserializeMenuButtonChild(child.payload, onMenuButtonPressed: onMenuButtonPressed)
        case "divider":
            AnyView(Divider())
        case "image":
            applyMenuBadge(to: CNImage.deserialize(child.payload) ?? AnyView(EmptyView()), badge: badgePayload(from: child.payload))
        case "label":
            applyMenuBadge(to: CNLabel.deserialize(child.payload) ?? AnyView(EmptyView()), badge: badgePayload(from: child.payload))
        case "text":
            applyMenuBadge(to: CNText.deserialize(child.payload) ?? AnyView(EmptyView()), badge: badgePayload(from: child.payload))
        default:
            AnyView(EmptyView())
        }
    }

    private static func deserializeMenuButtonChild(
        _ payloadMap: [String: Any],
        onMenuButtonPressed: ((Int) -> Void)? = nil,
    ) -> AnyView {
        guard let payload = CNButtonPayload(channel: payloadMap) else {
            return AnyView(EmptyView())
        }

        let childIndex = (payloadMap["menuChildIndex"] as? NSNumber)?.intValue ?? payloadMap["menuChildIndex"] as? Int
        let enabled = payload.viewModifiers.enabled ?? true
        let children = payload.buttonChildren.compactMap(deserializeButtonLabelChild)

        var button = AnyView(
            Button(role: buttonRole(from: payload.buttonRole)) {
                guard enabled else { return }
                if let childIndex {
                    onMenuButtonPressed?(childIndex)
                }
            } label: {
                buttonLabel(from: children)
            },
        )

        button = AnyView(button.disabled(!enabled))
        button = applyButtonStyle(to: button, buttonStyle: payload.buttonStyle)

        button = CNViewModifiers.apply(payload.viewModifiers, to: button)

        button = applyMenuBadge(to: button, badge: badgePayload(from: payloadMap))

        return button
    }

    private static func badgePayload(from payload: [String: Any]) -> [String: Any]? {
        payload["badge"] as? [String: Any]
    }

    private static func applyMenuBadge(to view: AnyView, badge: [String: Any]?) -> AnyView {
        guard let badge, let kind = badge["type"] as? String else {
            return view
        }

        switch kind {
        case "text":
            if let value = badge["payload"] as? String {
                return AnyView(view.badge(Text(value)))
            }
        case "value":
            if let value = badge["payload"] as? NSNumber {
                return AnyView(view.badge(value.intValue))
            }

            if let value = badge["payload"] as? Int {
                return AnyView(view.badge(value))
            }
        default:
            break
        }

        return view
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

    private static func applyMenuStyle(to view: AnyView, style: String?) -> AnyView {
        switch style {
        case "button":
            AnyView(view.menuStyle(ButtonMenuStyle()))
        case "borderlessButton":
            AnyView(view.menuStyle(BorderlessButtonMenuStyle()))
        case "borderedButton":
            AnyView(view.menuStyle(BorderedButtonMenuStyle()))
        default:
            AnyView(view.menuStyle(DefaultMenuStyle()))
        }
    }

    private static func applyControlSize(to view: AnyView, controlSize: String?) -> AnyView {
        switch controlSize {
        case "mini":
            return AnyView(view.controlSize(.mini))
        case "small":
            return AnyView(view.controlSize(.small))
        case "regular":
            return AnyView(view.controlSize(.regular))
        case "large":
            return AnyView(view.controlSize(.large))
        case "extraLarge":
            if #available(macOS 14.0, *) {
                return AnyView(view.controlSize(.extraLarge))
            }
            return AnyView(view.controlSize(.large))
        default:
            return AnyView(view.controlSize(.regular))
        }
    }

    private static func identityKey(for payload: CNMenuPayload) -> String {
        let childrenKey = payload.children.map { String(describing: $0.toChannel()) }.joined(separator: ";")
        let labelKey = payload.labelChildren.map { String(describing: $0.toChannel()) }.joined(separator: ";")
        let styleKey = payload.menuStyle ?? "nil"
        let darkKey = payload.isDark.map { String($0) } ?? "nil"
        let modifiersKey = payload.viewModifiers.identityKey()

        return [
            childrenKey,
            labelKey,
            styleKey,
            darkKey,
            modifiersKey,
        ].joined(separator: "|")
    }
}
