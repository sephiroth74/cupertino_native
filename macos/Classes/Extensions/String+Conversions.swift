import Swift
import SwiftUI

extension String {
    func toPickerStyle() -> any PickerStyle {
        switch self {
        case "segmented":
            return SegmentedPickerStyle()
        case "automatic":
            return DefaultPickerStyle()
        case "inline":
            return InlinePickerStyle()
        case "menu":
            return MenuPickerStyle()
        case "palette":
            return PalettePickerStyle()
        case "radioGroup":
            return RadioGroupPickerStyle()
        default:
            return DefaultPickerStyle()
        }
    }

    func toButtonStyle() -> any PrimitiveButtonStyle {
        switch self {
        case "automatic":
            return DefaultButtonStyle()
        case "bordered":
            return BorderedButtonStyle()
        case "borderedProminent":
            return BorderedProminentButtonStyle()
        case "borderless":
            return BorderlessButtonStyle()
        case "plain":
            return PlainButtonStyle()
        case "glass":
            return GlassButtonStyle()
        case "glassProminent":
            return GlassProminentButtonStyle()
        case "link":
            return LinkButtonStyle()
        case "accessoryBar":
            return AccessoryBarButtonStyle()
        case "accessoryBarAction":
            return AccessoryBarActionButtonStyle()
        default:
            return DefaultButtonStyle()
        }
    }

    func toSymbolRenderingMode() -> SymbolRenderingMode? {
        switch self {
        case "hierarchical":
            return .hierarchical
        case "palette":
            return .palette
        case "monochrome":
            return .monochrome
        default:
            return nil
        }
    }

    func toControlSize() -> ControlSize? {
        switch self {
        case "small":
            return .small
        case "regular":
            return .regular
        case "large":
            return .large
        case "mini":
            return .mini
        case "extraLarge":
            return .extraLarge
        default:
            return nil
        }
    }
}
