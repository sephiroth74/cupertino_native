import SwiftUI

enum CNViewModifiers {
    static func apply(_ modifiers: CNViewModifiersPayload?, to view: AnyView) -> AnyView {
        guard let modifiers else {
            return view
        }

        var modifiedView = view

        modifiedView = CNViewControlSize.apply(modifiers.controlSize, to: modifiedView)
        modifiedView = CNViewPadding.apply(modifiers.padding, to: modifiedView)
        modifiedView = CNViewTag.apply(modifiers.tag, to: modifiedView)
        modifiedView = CNViewEnabled.apply(modifiers.enabled, to: modifiedView)
        modifiedView = CNViewTint.apply(modifiers.tint, to: modifiedView)
        modifiedView = CNViewForegroundColor.apply(modifiers.foregroundColor, to: modifiedView)
        modifiedView = CNViewFrame.apply(
            constraints: modifiers.constraints,
            shrinkWrap: modifiers.shrinkWrap,
            to: modifiedView,
        )
        return modifiedView
    }
}

enum CNViewFrame {
    static func apply(constraints: CNViewConstraintsPayload?, shrinkWrap: Bool, to view: AnyView) -> AnyView {
        guard !shrinkWrap, let constraints else {
            return view
        }

        let minWidth = constraints.minWidth.map { CGFloat($0) }
        let idealWidth = constraints.tightWidth.map { CGFloat($0) }
        let maxWidth = constraints.maxWidth.map { CGFloat($0) }
        let minHeight = constraints.minHeight.map { CGFloat($0) }
        let idealHeight = constraints.tightHeight.map { CGFloat($0) }
        let maxHeight = constraints.maxHeight.map { CGFloat($0) }

        let framed = view.frame(
            minWidth: minWidth,
            idealWidth: idealWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            idealHeight: idealHeight,
            maxHeight: maxHeight,
        )

        return AnyView(framed)
    }
}

enum CNViewForegroundColor {
    static func apply(_ foregroundColor: Int?, to view: AnyView) -> AnyView {
        guard let foregroundColor else {
            return view
        }

        return AnyView(view.foregroundColor(ColorUtils.swiftUIColorFromARGB(foregroundColor)))
    }
}

enum CNViewTint {
    static func apply(_ tint: Int?, to view: AnyView) -> AnyView {
        guard let tint else {
            return view
        }

        return AnyView(view.tint(ColorUtils.swiftUIColorFromARGB(tint)))
    }
}

enum CNViewEnabled {
    static func apply(_ enabled: Bool?, to view: AnyView) -> AnyView {
        guard let enabled else {
            return view
        }

        return AnyView(view.disabled(!enabled))
    }
}

enum CNViewControlSize {
    static func fromString(_ string: String?) -> ControlSize? {
        switch string {
        case "mini":
            return .mini
        case "small":
            return .small
        case "regular":
            return .regular
        case "large":
            return .large
        case "extraLarge":
            if #available(macOS 14.0, *) {
                return .extraLarge
            }
            return .large
        default:
            return nil
        }
    }

    static func apply(_ controlSize: String?, to view: AnyView) -> AnyView {
        guard let controlSize = fromString(controlSize) else {
            return view
        }

        return AnyView(view.controlSize(controlSize))
    }
}

enum CNViewPadding {
    static func edgeInsets(from raw: [String: Any]?) -> EdgeInsets? {
        guard let raw else { return nil }

        let top = (raw["top"] as? NSNumber)?.doubleValue ?? (raw["top"] as? Double) ?? 0
        let leading = (raw["leading"] as? NSNumber)?.doubleValue ?? (raw["leading"] as? Double) ?? 0
        let bottom = (raw["bottom"] as? NSNumber)?.doubleValue ?? (raw["bottom"] as? Double) ?? 0
        let trailing = (raw["trailing"] as? NSNumber)?.doubleValue ?? (raw["trailing"] as? Double) ?? 0

        return EdgeInsets(
            top: CGFloat(top),
            leading: CGFloat(leading),
            bottom: CGFloat(bottom),
            trailing: CGFloat(trailing),
        )
    }

    static func apply(_ padding: [String: Any]?, to view: AnyView) -> AnyView {
        guard let insets = edgeInsets(from: padding) else {
            return view
        }

        return AnyView(view.padding(insets))
    }
}

enum CNViewTag {
    static func parse(from channel: [String: Any]) -> AnyHashable? {
        if let number = channel["tag"] as? NSNumber {
            return number.intValue
        }

        if let intValue = channel["tag"] as? Int {
            return intValue
        }

        if let stringValue = channel["tag"] as? String {
            return stringValue
        }

        return nil
    }

    static func apply(_ tag: AnyHashable?, to view: AnyView) -> AnyView {
        guard let tag else {
            return view
        }

        if let intTag = tag.base as? Int {
            return AnyView(view.tag(intTag))
        }

        if let stringTag = tag.base as? String {
            return AnyView(view.tag(stringTag))
        }

        return view
    }
}
