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
}
