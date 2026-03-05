import Cocoa

class ControlSizeUtils {
    static func controlSizeFromString(_ size: String) -> NSControl.ControlSize {
        switch size {
        case "small":
            return .small
        case "regular":
            return .regular
        case "large":
            return .large
        case "mini":
            return .mini
        case "extraLarge":
            if #available(macOS 26.0, *) {
                return .extraLarge
            } else {
                return .large
            }
        default:
            return .regular
        }
    }
}
