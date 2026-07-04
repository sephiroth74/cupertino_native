import Cocoa

struct CNColorWellPayload: CNChannelSerializable {
    let color: Int?
    let continuous: Bool?
    let enabled: Bool?
    let isDark: Bool?
    let style: String?
    let supportsAlpha: Bool?

    init?(channel: [String: Any]) {
        color = (channel["color"] as? NSNumber)?.intValue ?? channel["color"] as? Int
        continuous = (channel["continuous"] as? NSNumber)?.boolValue ?? channel["continuous"] as? Bool
        enabled = (channel["enabled"] as? NSNumber)?.boolValue ?? channel["enabled"] as? Bool
        isDark = (channel["isDark"] as? NSNumber)?.boolValue ?? channel["isDark"] as? Bool
        style = channel["style"] as? String
        supportsAlpha = (channel["supportsAlpha"] as? NSNumber)?.boolValue ?? channel["supportsAlpha"] as? Bool
    }

    func toChannel() -> [String: Any] {
        [
            "color": color as Any,
            "continuous": continuous as Any,
            "enabled": enabled as Any,
            "isDark": isDark as Any,
            "style": style as Any,
            "supportsAlpha": supportsAlpha as Any,
        ]
    }
}

enum CNColorWellDeserializer {
    static func decode(_ raw: Any?) -> CNColorWellPayload? {
        CNChannelSerialization.decode(raw)
    }

    static func apply(payload: CNColorWellPayload, to colorWell: NSColorWell, in container: NSView) {
        if let color = payload.color {
            colorWell.color = ColorUtils.colorFromARGB(color)
        }

        colorWell.isContinuous = payload.continuous ?? true
        colorWell.supportsAlpha = payload.supportsAlpha ?? true
        colorWell.isEnabled = payload.enabled ?? true
        colorWell.colorWellStyle = parseStyle(payload.style)

        if let isDark = payload.isDark {
            container.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        } else {
            container.appearance = nil
        }
    }

    static func parseStyle(_ style: String?) -> NSColorWell.Style {
        switch style {
        case "minimal":
            .minimal
        case "expanded":
            .expanded
        default:
            .default
        }
    }
}
