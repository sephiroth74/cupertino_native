import Cocoa

class ControlSizeUtils {
    static func controlSizeFromString(_ size: String) -> NSControl.ControlSize {
        switch size {
        case "small":
            .small
        case "regular":
            .regular
        case "large":
            .large
        case "mini":
            .mini
        case "extraLarge":
            if #available(macOS 26.0, *) {
                .extraLarge
            } else {
                .large
            }
        default:
            .regular
        }
    }
}
