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
        guard let constraints else {
            return view
        }

        let minWidth = constraints.minWidth
        let idealWidth = constraints.tightWidth
        let maxWidth = constraints.maxWidth
        let minHeight = constraints.minHeight
        let idealHeight = constraints.tightHeight
        let maxHeight = constraints.maxHeight

        if shrink {
            // In shrink mode, width constraint is handled via AutoLayout on the hosting view.
            // SwiftUI .frame(maxWidth:) doesn't propagate to fittingSize correctly.
            return AnyView(
                view.frame(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                ),
            )
        }

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

    static func applyControlSize(_ size: String?, to view: AnyView) -> AnyView {
        switch size {
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

    static func applyEnabled(_ enabled: Bool?, to view: AnyView) -> AnyView {
        guard let enabled else {
            return view
        }
        return AnyView(view.disabled(!enabled))
    }

    static func applyLabelStyle(_ style: String?, to view: AnyView) -> AnyView {
        guard let style else {
            return view
        }
        switch style {
        case "titleOnly":
            return AnyView(view.labelStyle(.titleOnly))
        case "iconOnly":
            return AnyView(view.labelStyle(.iconOnly))
        case "titleAndIcon":
            return AnyView(view.labelStyle(.titleAndIcon))
        default:
            return view
        }
    }

    static func applyButtonStyle(_ style: String?, to view: AnyView) -> AnyView {
        switch style {
        case "plain":
            AnyView(view.buttonStyle(PlainButtonStyle()))
        case "borderless":
            AnyView(view.buttonStyle(BorderlessButtonStyle()))
        case "link":
            AnyView(view.buttonStyle(LinkButtonStyle()))
        case "bordered":
            AnyView(view.buttonStyle(BorderedButtonStyle()))
        case "borderedProminent":
            AnyView(view.buttonStyle(BorderedProminentButtonStyle()))
        case "accessoryBar":
            if #available(macOS 14.0, *) {
                AnyView(view.buttonStyle(AccessoryBarButtonStyle()))
            } else {
                view
            }
        case "accessoryBarAction":
            if #available(macOS 14.0, *) {
                AnyView(view.buttonStyle(AccessoryBarActionButtonStyle()))
            } else {
                view
            }
        case "glass":
            if #available(macOS 26.0, *) {
                AnyView(view.buttonStyle(GlassButtonStyle()))
            } else {
                AnyView(view.buttonStyle(BorderedButtonStyle()))
            }
        case "prominentGlass", "glassProminent":
            if #available(macOS 26.0, *) {
                AnyView(view.buttonStyle(GlassProminentButtonStyle()))
            } else {
                AnyView(view.buttonStyle(BorderedProminentButtonStyle()))
            }
        default:
            view
        }
    }
}
