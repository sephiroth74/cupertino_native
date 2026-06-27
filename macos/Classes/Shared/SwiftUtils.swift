import SwiftUI

class SwiftUtils {
    static func controlSizeFromString(_ size: String?) -> ControlSize {
        switch size {
        case "small":
            return ControlSize.small
        case "regular":
            return ControlSize.regular
        case "large":
            return ControlSize.large
        case "mini":
            return ControlSize.mini
        case "extraLarge":
            return ControlSize.extraLarge
        default:
            return ControlSize.regular
        }
    }

    static func pickerStyleFromString(_ style: String?) -> PickerStyle {
        switch style {
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
            return SegmentedPickerStyle()
        }
    }
}