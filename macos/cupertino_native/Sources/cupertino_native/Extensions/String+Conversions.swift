import Swift
import SwiftUI

extension String {
    func toButtonStyle() -> any PrimitiveButtonStyle {
        switch self {
        case "automatic":
            DefaultButtonStyle()
        case "bordered":
            BorderedButtonStyle()
        case "borderedProminent":
            BorderedProminentButtonStyle()
        case "borderless":
            BorderlessButtonStyle()
        case "plain":
            PlainButtonStyle()
        case "glass":
            GlassButtonStyle()
        case "glassProminent", "prominentGlass":
            GlassProminentButtonStyle()
        case "link":
            LinkButtonStyle()
        case "accessoryBar":
            AccessoryBarButtonStyle()
        case "accessoryBarAction":
            AccessoryBarActionButtonStyle()
        default:
            DefaultButtonStyle()
        }
    }

    func toSymbolRenderingMode() -> SymbolRenderingMode? {
        switch self {
        case "hierarchical":
            .hierarchical
        case "palette":
            .palette
        case "monochrome":
            .monochrome
        default:
            nil
        }
    }

    func toControlSize() -> ControlSize? {
        switch self {
        case "small":
            .small
        case "regular":
            .regular
        case "large":
            .large
        case "mini":
            .mini
        case "extraLarge":
            .extraLarge
        default:
            nil
        }
    }
}
