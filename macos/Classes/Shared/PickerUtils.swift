import SwiftUI

class PickerUtils {
    static func pickerStyleFromString(_ style: String) -> any PickerStyle {
        switch style {
        case "segmented":
            .segmented
        case "automatic":
            .automatic
        case "inline":
            .inline
        case "menu":
            .menu
        case "palette":
            .palette
        case "radioGroup":
            .radioGroup
        default:
            SegmentedPickerStyle()
        }
    }
}
