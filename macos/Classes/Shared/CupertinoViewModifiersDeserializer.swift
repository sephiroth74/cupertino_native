import Foundation

struct CNViewModifiersPayload {
    var tag: AnyHashable?
    var padding: [String: Any]?
    var controlSize: String?
    var enabled: Bool?
    var tint: Int?
    var foregroundColor: Int?
    var width: Double?
    var height: Double?

    init() {}

    init(channel: [String: Any]) {
        self.init()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        if channel.keys.contains("tag") {
            tag = CNViewTag.parse(from: channel)
        }

        if channel.keys.contains("padding") {
            if channel["padding"] is NSNull {
                padding = nil
            } else {
                padding = channel["padding"] as? [String: Any]
            }
        }

        if channel.keys.contains("controlSize") {
            controlSize = Self.decodeString(channel["controlSize"])
        }

        if channel.keys.contains("enabled") {
            enabled = Self.decodeBool(channel["enabled"])
        }

        if channel.keys.contains("width") {
            width = Self.decodeDouble(channel["width"])
        }

        if channel.keys.contains("height") {
            height = Self.decodeDouble(channel["height"])
        }

        if channel.keys.contains("tint") {
            tint = Self.decodeInt(channel["tint"])
        }

        if channel.keys.contains("foregroundColor") {
            foregroundColor = Self.decodeInt(channel["foregroundColor"])
        }

        if let style = channel["style"] as? [String: Any] {
            if style.keys.contains("tint") {
                tint = Self.decodeInt(style["tint"])
            }

            if style.keys.contains("foregroundColor") {
                foregroundColor = Self.decodeInt(style["foregroundColor"])
            }
        }
    }

    func toChannel() -> [String: Any] {
        var result: [String: Any] = [:]

        if let tag {
            result["tag"] = tag.base
        }

        if let padding {
            result["padding"] = padding
        }

        if let controlSize {
            result["controlSize"] = controlSize
        }

        if let enabled {
            result["enabled"] = enabled
        }

        if let width {
            result["width"] = width
        }

        if let height {
            result["height"] = height
        }

        if let tint {
            result["tint"] = tint
        }

        if let foregroundColor {
            result["foregroundColor"] = foregroundColor
        }

        return result
    }

    func identityKey() -> String {
        let tagKey = if let tag {
            "\(tag.base)"
        } else {
            "nil"
        }

        let paddingKey = if let padding {
            "\(padding)"
        } else {
            "nil"
        }

        let controlSizeKey = controlSize ?? "nil"
        let enabledKey = enabled.map { "\($0)" } ?? "nil"
        let widthKey = width.map { "\($0)" } ?? "nil"
        let heightKey = height.map { "\($0)" } ?? "nil"
        let tintKey = tint.map { "\($0)" } ?? "nil"
        let foregroundColorKey = foregroundColor.map { "\($0)" } ?? "nil"

        return [
            tagKey,
            paddingKey,
            controlSizeKey,
            enabledKey,
            widthKey,
            heightKey,
            tintKey,
            foregroundColorKey,
        ].joined(separator: "|")
    }

    private static func decodeBool(_ value: Any?) -> Bool? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.boolValue ?? value as? Bool
    }

    private static func decodeInt(_ value: Any?) -> Int? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.intValue ?? value as? Int
    }

    private static func decodeDouble(_ value: Any?) -> Double? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.doubleValue ?? value as? Double
    }

    private static func decodeString(_ value: Any?) -> String? {
        if value is NSNull { return nil }
        return value as? String
    }
}
