import SwiftUI

class SwiftUtils {
    static func controlSizeFromString(_ size: String?) -> ControlSize {
        switch size {
        case "small":
            ControlSize.small
        case "regular":
            ControlSize.regular
        case "large":
            ControlSize.large
        case "mini":
            ControlSize.mini
        case "extraLarge":
            ControlSize.extraLarge
        default:
            ControlSize.regular
        }
    }
}
