import SwiftUI

class PickerUtils {
    static func pickerStyleFromString(_ style: String) -> any PickerStyle {
        switch style {
        case "segmented":
            return .segmented
        case "automatic":
            return .automatic
        case "inline":
            return .inline
        case "menu":
            return .menu
        case "palette":
            return .palette
        case "radioGroup":
            return .radioGroup
        default:
            return SegmentedPickerStyle()
        }
    }
}