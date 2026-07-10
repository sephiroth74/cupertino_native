import SwiftUI

/// Shared SwiftUI view modifier applicators for CN widgets.
/// These are the common modifiers that most widgets will need.
enum CNViewModifierApplicator {
    static func applyPaddings(_ paddings: CNPaddingsPayload?, to view: AnyView) -> AnyView {
        guard let paddings else {
            return view
        }
        return AnyView(
            view.padding(
                EdgeInsets(
                    top: paddings.top,
                    leading: paddings.leading,
                    bottom: paddings.bottom,
                    trailing: paddings.trailing,
                ),
            ),
        )
    }

    static func applyConstraints(constraints: CNBoxConstraintsPayload?, shrink: Bool, to view: AnyView) -> AnyView {
        guard let constraints, shrink == false else {
            return view
        }

        let minWidth = constraints.minWidth.map { CGFloat($0) }
        let idealWidth = constraints.tightWidth.map { CGFloat($0) }
        let maxWidth = constraints.maxWidth.map { CGFloat($0) }
        let minHeight = constraints.minHeight.map { CGFloat($0) }
        let idealHeight = constraints.tightHeight.map { CGFloat($0) }
        let maxHeight = constraints.maxHeight.map { CGFloat($0) }

        return AnyView(
            view.frame(
                minWidth: minWidth,
                idealWidth: idealWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                idealHeight: idealHeight,
                maxHeight: maxHeight,
            ),
        )
    }

    static func applyFont(_ fontDict: [String: Any]?, to view: AnyView) -> AnyView {
        guard let fontDict else {
            return view
        }
        if let font = FontUtils.swiftUIFontFromDictionary(fontDict) {
            return AnyView(view.font(font))
        }
        return view
    }

    static func applyForegroundColor(_ foregroundColor: Int?, to view: AnyView) -> AnyView {
        guard let foregroundColor else {
            return view
        }
        return AnyView(view.foregroundColor(ColorUtils.swiftUIColorFromARGB(foregroundColor)))
    }

    static func applyTint(_ tint: Int?, to view: AnyView) -> AnyView {
        guard let tint else {
            return view
        }
        return AnyView(view.tint(ColorUtils.swiftUIColorFromARGB(tint)))
    }
}
