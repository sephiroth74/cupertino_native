import SwiftUI

struct CNLabelPayload: CNChannelSerializable {
    var primaryText: [String: Any]
    var secondaryText: [String: Any]?
    var icon: [String: Any]?
    var labelStyle: String?
    var labelReservedIconWidth: Double?
    var labelIconToTitleSpacing: Double?
    var viewModifiers: CNViewModifiersPayload

    init() {
        primaryText = ["text": ""]
        secondaryText = nil
        icon = nil
        labelStyle = nil
        labelReservedIconWidth = nil
        labelIconToTitleSpacing = nil
        viewModifiers = CNViewModifiersPayload()
    }

    init?(channel: [String: Any]) {
        guard let nodes = channel["nodes"] as? [String: Any],
              let primaryText = nodes["primaryText"] as? [String: Any]
        else {
            return nil
        }

        self.init()
        self.primaryText = primaryText
        secondaryText = nodes["secondaryText"] as? [String: Any]
        icon = nodes["icon"] as? [String: Any]
        labelStyle = channel["labelStyle"] as? String
        labelReservedIconWidth = (channel["labelReservedIconWidth"] as? NSNumber)?.doubleValue ?? channel["labelReservedIconWidth"] as? Double
        labelIconToTitleSpacing = (channel["labelIconToTitleSpacing"] as? NSNumber)?.doubleValue ?? channel["labelIconToTitleSpacing"] as? Double
        viewModifiers = CNViewModifiersPayload(channel: channel)
    }

    func toChannel() -> [String: Any] {
        var result = viewModifiers.toChannel()
        result["nodes"] = [
            "primaryText": primaryText,
            "secondaryText": secondaryText as Any,
            "icon": icon as Any,
        ]
        result["labelStyle"] = labelStyle
        result["labelReservedIconWidth"] = labelReservedIconWidth
        result["labelIconToTitleSpacing"] = labelIconToTitleSpacing
        return result
    }
}

final class CNLabelViewModel: ObservableObject {
    @Published private(set) var primaryText: CNTextViewModel
    @Published private(set) var secondaryText: CNTextViewModel?
    @Published private(set) var icon: CNImageViewModel?
    @Published private(set) var labelStyle: String?
    @Published private(set) var labelReservedIconWidth: Double?
    @Published private(set) var labelIconToTitleSpacing: Double?
    @Published private(set) var viewModifiers: CNViewModifiersPayload

    init(payload: CNLabelPayload) {
        let primaryPayload = CNTextPayload(channel: payload.primaryText) ?? CNTextPayload(channel: ["text": ""])!
        primaryText = CNTextViewModel(payload: primaryPayload)

        if let secondary = payload.secondaryText,
           let secondaryPayload = CNTextPayload(channel: secondary)
        {
            secondaryText = CNTextViewModel(payload: secondaryPayload)
        } else {
            secondaryText = nil
        }

        if let iconMap = payload.icon,
           let iconPayload = CNImagePayload(channel: iconMap)
        {
            icon = CNImageViewModel(payload: iconPayload)
        } else {
            icon = nil
        }

        labelStyle = payload.labelStyle
        labelReservedIconWidth = payload.labelReservedIconWidth
        labelIconToTitleSpacing = payload.labelIconToTitleSpacing
        viewModifiers = payload.viewModifiers
    }

    func replace(with payload: CNLabelPayload) {
        if let nextPrimary = CNTextPayload(channel: payload.primaryText) {
            primaryText.replace(with: nextPrimary)
        }

        if let secondaryMap = payload.secondaryText,
           let secondaryPayload = CNTextPayload(channel: secondaryMap)
        {
            if let current = secondaryText {
                current.replace(with: secondaryPayload)
            } else {
                secondaryText = CNTextViewModel(payload: secondaryPayload)
            }
        } else {
            secondaryText = nil
        }

        if let iconMap = payload.icon,
           let iconPayload = CNImagePayload(channel: iconMap)
        {
            if let current = icon {
                current.replace(with: iconPayload)
            } else {
                icon = CNImageViewModel(payload: iconPayload)
            }
        } else {
            icon = nil
        }

        labelStyle = payload.labelStyle
        labelReservedIconWidth = payload.labelReservedIconWidth
        labelIconToTitleSpacing = payload.labelIconToTitleSpacing
        viewModifiers = payload.viewModifiers
    }

    func applyPatch(_ patch: [String: Any]) {
        if patch.keys.contains("labelStyle") {
            labelStyle = decodeString(patch["labelStyle"])
        }

        if patch.keys.contains("labelReservedIconWidth") {
            labelReservedIconWidth = decodeDouble(patch["labelReservedIconWidth"])
        }

        if patch.keys.contains("labelIconToTitleSpacing") {
            labelIconToTitleSpacing = decodeDouble(patch["labelIconToTitleSpacing"])
        }

        viewModifiers.applyPatch(patch)

        if let nodes = patch["nodes"] as? [String: Any] {
            if let primaryPatch = nodes["primaryText"] as? [String: Any] {
                primaryText.applyPatch(primaryPatch)
            }

            if nodes.keys.contains("secondaryText") {
                if nodes["secondaryText"] is NSNull {
                    secondaryText = nil
                } else if let secondaryPatch = nodes["secondaryText"] as? [String: Any] {
                    if let current = secondaryText {
                        current.applyPatch(secondaryPatch)
                    } else if let payload = CNTextPayload(channel: secondaryPatch) {
                        secondaryText = CNTextViewModel(payload: payload)
                    }
                }
            }

            if nodes.keys.contains("icon") {
                if nodes["icon"] is NSNull {
                    icon = nil
                } else if let iconPatch = nodes["icon"] as? [String: Any] {
                    if let current = icon {
                        current.applyPatch(iconPatch)
                    } else if let payload = CNImagePayload(channel: iconPatch) {
                        icon = CNImageViewModel(payload: payload)
                    }
                }
            }
        }

        objectWillChange.send()
    }

    private func decodeDouble(_ value: Any?) -> Double? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.doubleValue ?? value as? Double
    }

    private func decodeString(_ value: Any?) -> String? {
        if value is NSNull { return nil }
        return value as? String
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

    static func deserialize(model: CNLabelViewModel, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        AnyView(_CNBoundLabelView(model: model, onSizeChanged: onSizeChanged))
    }

    private static func view(from payload: CNLabelPayload, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        var view = buildBaseLabel(from: payload)

        if let width = payload.viewModifiers.width, let height = payload.viewModifiers.height {
            view = AnyView(view.frame(width: CGFloat(width), height: CGFloat(height)))
        } else if let width = payload.viewModifiers.width {
            view = AnyView(view.frame(width: CGFloat(width)))
        } else if let height = payload.viewModifiers.height {
            view = AnyView(view.frame(height: CGFloat(height)))
        }

        view = CNViewTag.apply(payload.viewModifiers.tag, to: view)
        view = CNViewPadding.apply(payload.viewModifiers.padding, to: view)

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

    private struct _CNBoundLabelView: View {
        @ObservedObject var model: CNLabelViewModel
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            var view = buildBaseLabel(
                primary: CNText.deserialize(model: model.primaryText),
                secondary: model.secondaryText.map { CNText.deserialize(model: $0) },
                icon: model.icon.map { CNImage.deserialize(model: $0) },
                style: model.labelStyle,
                reservedIconWidth: model.labelReservedIconWidth,
                iconToTitleSpacing: model.labelIconToTitleSpacing,
            )

            if let width = model.viewModifiers.width, let height = model.viewModifiers.height {
                view = AnyView(view.frame(width: CGFloat(width), height: CGFloat(height)))
            } else if let width = model.viewModifiers.width {
                view = AnyView(view.frame(width: CGFloat(width)))
            } else if let height = model.viewModifiers.height {
                view = AnyView(view.frame(height: CGFloat(height)))
            }

            view = CNViewTag.apply(model.viewModifiers.tag, to: view)
            view = CNViewPadding.apply(model.viewModifiers.padding, to: view)

            if let onSizeChanged {
                view = AnyView(
                    view.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newSize in
                        onSizeChanged(newSize)
                    },
                )
            }

            return view
        }
    }

    private static func buildBaseLabel(from payload: CNLabelPayload) -> AnyView {
        let primary = CNText.deserialize(payload.primaryText)
        let secondary = payload.secondaryText.flatMap { CNText.deserialize($0) }
        let icon = payload.icon.flatMap { CNImage.deserialize($0) }

        return buildBaseLabel(
            primary: primary,
            secondary: secondary,
            icon: icon,
            style: payload.labelStyle,
            reservedIconWidth: payload.labelReservedIconWidth,
            iconToTitleSpacing: payload.labelIconToTitleSpacing,
        )
    }

    private static func buildBaseLabel(
        primary: AnyView?,
        secondary: AnyView?,
        icon: AnyView?,
        style: String?,
        reservedIconWidth: Double?,
        iconToTitleSpacing: Double?,
    ) -> AnyView {
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

        label = applyLabelStyle(to: label, style: style)

        if #available(macOS 26.0, *) {
            if let reservedIconWidth {
                label = AnyView(label.labelReservedIconWidth(reservedIconWidth))
            }
            if let iconToTitleSpacing {
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
        let paddingKey = payload.viewModifiers.padding.map { String(describing: $0) } ?? "nil"
        let tagKey = payload.viewModifiers.tag.map { "\($0)" } ?? "nil"
        let widthKey = payload.viewModifiers.width.map { "\($0)" } ?? "nil"
        let heightKey = payload.viewModifiers.height.map { "\($0)" } ?? "nil"

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
