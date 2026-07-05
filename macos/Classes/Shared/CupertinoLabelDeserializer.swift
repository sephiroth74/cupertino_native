import SwiftUI

struct CNLabelPayload: CNChannelSerializable {
    let primaryText: [String: Any]
    let secondaryText: [String: Any]?
    let icon: [String: Any]?
    let padding: [String: Any]?
    let tag: AnyHashable?
    let labelStyle: String?
    let labelReservedIconWidth: Double?
    let labelIconToTitleSpacing: Double?
    let width: Double?
    let height: Double?
    let viewModifiers: CNViewModifiersPayload

    init?(channel: [String: Any]) {
        guard let primaryText = channel["primaryText"] as? [String: Any] else {
            return nil
        }

        let modifiers = CNViewModifiersPayload(channel: channel)
        self.primaryText = primaryText
        secondaryText = channel["secondaryText"] as? [String: Any]
        icon = channel["icon"] as? [String: Any]
        padding = modifiers.padding
        tag = modifiers.tag
        labelStyle = channel["labelStyle"] as? String
        labelReservedIconWidth = (channel["labelReservedIconWidth"] as? NSNumber)?.doubleValue ?? channel["labelReservedIconWidth"] as? Double
        labelIconToTitleSpacing = (channel["labelIconToTitleSpacing"] as? NSNumber)?.doubleValue ?? channel["labelIconToTitleSpacing"] as? Double
        width = modifiers.width
        height = modifiers.height
        viewModifiers = modifiers
    }

    func toChannel() -> [String: Any] {
        var result = viewModifiers.toChannel()
        result["primaryText"] = primaryText
        result["secondaryText"] = secondaryText
        result["icon"] = icon
        result["labelStyle"] = labelStyle
        result["labelReservedIconWidth"] = labelReservedIconWidth
        result["labelIconToTitleSpacing"] = labelIconToTitleSpacing
        return result
    }
}

enum CNLabel {
    static func deserialize(_ raw: Any?, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView? {
        if let payload: CNLabelPayload = CNChannelSerialization.decode(raw) {
            return view(from: payload, onSizeChanged: onSizeChanged)
        }

        if let jsonString = raw as? String {
            return deserialize(jsonString: jsonString, onSizeChanged: onSizeChanged)
        }

        return nil
    }

    static func deserialize(jsonString: String, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView? {
        do {
            if let dict = try JSONSerialization.jsonObject(with: Data(jsonString.utf8), options: []) as? [String: Any] {
                return deserialize(dict, onSizeChanged: onSizeChanged)
            }
        } catch {
            NSLog("Error deserializing label JSON string: \(error)")
        }

        return nil
    }

    static func deserialize(_ dict: [String: Any], onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView? {
        guard let payload = CNLabelPayload(channel: dict) else {
            return nil
        }

        return view(from: payload, onSizeChanged: onSizeChanged)
    }

    private static func view(from payload: CNLabelPayload, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        var view = buildBaseLabel(from: payload)

        if let width = payload.width, let height = payload.height {
            view = AnyView(view.frame(width: CGFloat(width), height: CGFloat(height)))
        } else if let width = payload.width {
            view = AnyView(view.frame(width: CGFloat(width)))
        } else if let height = payload.height {
            view = AnyView(view.frame(height: CGFloat(height)))
        }

        view = CNViewTag.apply(payload.tag, to: view)

        view = CNViewPadding.apply(payload.padding, to: view)

        if let onSizeChanged {
            view = AnyView(
                view.onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newSize in
                    onSizeChanged(newSize)
                },
            )
        }

        return AnyView(view.id(identityKey(for: payload)))
    }

    private static func buildBaseLabel(from payload: CNLabelPayload) -> AnyView {
        let primary = CNText.deserialize(payload.primaryText)
        let secondary = payload.secondaryText.flatMap { CNText.deserialize($0) }
        let icon = payload.icon.flatMap { CNImage.deserialize($0) }

        let hasPrimary = primary != nil
        let hasSecondary = secondary != nil
        let hasIcon = icon != nil

        var label

            // Case: Label { Text("First") Text("Second") } icon: { Image(...) }
            = if hasPrimary, hasSecondary, hasIcon
        {
            AnyView(
                Label {
                    primary!
                    secondary!
                } icon: {
                    icon!
                },
            )
        }
        // Case: Label { Text("First") Text("Second") } icon: { }
        else if hasPrimary, hasSecondary {
            AnyView(
                Label {
                    primary!
                    secondary!
                } icon: {
                    EmptyView()
                },
            )
        }
        // Case: Label { Text("First") } icon: { Image(...) }
        else if hasPrimary, hasIcon {
            AnyView(
                Label {
                    primary!
                } icon: {
                    icon!
                },
            )
        }
        // Case: Label { Text("First") } icon: { }
        else if hasPrimary {
            AnyView(
                Label {
                    primary!
                } icon: {
                    EmptyView()
                },
            )
        }
        // Case: Label { } icon: { Image(...) }
        else if hasIcon {
            AnyView(
                Label {
                    EmptyView()
                } icon: {
                    icon!
                },
            )
        }
        // Case: Label { } icon: { }
        else {
            AnyView(
                Label {
                    EmptyView()
                } icon: {
                    EmptyView()
                },
            )
        }

        label = applyLabelStyle(to: label, style: payload.labelStyle)

        if #available(macOS 26.0, *) {
            if let reservedIconWidth = payload.labelReservedIconWidth {
                label = AnyView(label.labelReservedIconWidth(reservedIconWidth))
            }
            if let iconToTitleSpacing = payload.labelIconToTitleSpacing {
                label = AnyView(label.labelIconToTitleSpacing(iconToTitleSpacing))
            }
        }

        return label
    }

    private static func applyLabelStyle(to view: AnyView, style: String?) -> AnyView {
        switch style {
        case "titleOnly":
            AnyView(view.labelStyle(.titleOnly))
        case "iconOnly":
            AnyView(view.labelStyle(.iconOnly))
        case "titleAndIcon":
            AnyView(view.labelStyle(.titleAndIcon))
        default:
            view
        }
    }

    private static func identityKey(for payload: CNLabelPayload) -> String {
        let secondaryKey = payload.secondaryText.map { String(describing: $0) } ?? "nil"
        let iconKey = payload.icon.map { String(describing: $0) } ?? "nil"
        let labelStyleKey = payload.labelStyle ?? "nil"
        let reservedWidthKey = payload.labelReservedIconWidth.map { "\($0)" } ?? "nil"
        let spacingKey = payload.labelIconToTitleSpacing.map { "\($0)" } ?? "nil"
        let paddingKey = payload.padding.map { String(describing: $0) } ?? "nil"
        let tagKey = payload.tag.map { "\($0)" } ?? "nil"
        let widthKey = payload.width.map { "\($0)" } ?? "nil"
        let heightKey = payload.height.map { "\($0)" } ?? "nil"

        return [
            String(describing: payload.primaryText),
            secondaryKey,
            iconKey,
            labelStyleKey,
            reservedWidthKey,
            spacingKey,
            paddingKey,
            tagKey,
            widthKey,
            heightKey,
        ].joined(separator: "|")
    }
}
