import Foundation

struct CNViewConstraintsPayload {
    var minWidth: Double?
    var maxWidth: Double?
    var minHeight: Double?
    var maxHeight: Double?
    var tightWidth: Double?
    var tightHeight: Double?

    init(
        minWidth: Double? = nil,
        maxWidth: Double? = nil,
        minHeight: Double? = nil,
        maxHeight: Double? = nil,
        tightWidth: Double? = nil,
        tightHeight: Double? = nil,
    ) {
        self.minWidth = minWidth
        self.tightWidth = tightWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.tightHeight = tightHeight
        self.maxHeight = maxHeight
    }

    static func fromChannel(_ value: Any?) -> CNViewConstraintsPayload? {
        guard let map = value as? [String: Any] else {
            return nil
        }

        return CNViewConstraintsPayload(
            minWidth: CNViewModifiersPayload.decodeDouble(map["minWidth"]),
            maxWidth: CNViewModifiersPayload.decodeDouble(map["maxWidth"]),
            minHeight: CNViewModifiersPayload.decodeDouble(map["minHeight"]),
            maxHeight: CNViewModifiersPayload.decodeDouble(map["maxHeight"]),
            tightWidth: CNViewModifiersPayload.decodeDouble(map["tightWidth"]),
            tightHeight: CNViewModifiersPayload.decodeDouble(map["tightHeight"]),
        )
    }

    func toChannel() -> [String: Any] {
        var result: [String: Any] = [:]

        if let minWidth {
            result["minWidth"] = minWidth
        }
        if let tightWidth {
            result["tightWidth"] = tightWidth
        }
        if let maxWidth {
            result["maxWidth"] = maxWidth
        }
        if let minHeight {
            result["minHeight"] = minHeight
        }
        if let tightHeight {
            result["tightHeight"] = tightHeight
        }
        if let maxHeight {
            result["maxHeight"] = maxHeight
        }

        return result
    }

    func identityKey() -> String {
        [
            minWidth.map { "\($0)" } ?? "nil",
            tightWidth.map { "\($0)" } ?? "nil",
            maxWidth.map { "\($0)" } ?? "nil",
            minHeight.map { "\($0)" } ?? "nil",
            tightHeight.map { "\($0)" } ?? "nil",
            maxHeight.map { "\($0)" } ?? "nil",
        ].joined(separator: "|")
    }
}

struct CNViewModifiersPayload {
    var tag: AnyHashable?
    var padding: [String: Any]?
    var controlSize: String?
    var enabled: Bool?
    var shrinkWrap: Bool
    var constraints: CNViewConstraintsPayload?
    var tint: Int?
    var foregroundColor: Int?

    /// Legacy compatibility helpers for callsites still reading width/height.
    var width: Double? {
        constraints?.minWidth == constraints?.maxWidth ? constraints?.maxWidth : nil
    }

    var height: Double? {
        constraints?.minHeight == constraints?.maxHeight ? constraints?.maxHeight : nil
    }

    init() {
        shrinkWrap = true
    }

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

        if channel.keys.contains("shrinkWrap") {
            shrinkWrap = Self.decodeBool(channel["shrinkWrap"]) ?? true
        }

        if channel.keys.contains("constraints") {
            if channel["constraints"] is NSNull {
                constraints = nil
            } else {
                constraints = CNViewConstraintsPayload.fromChannel(channel["constraints"])
            }
        }

        // Legacy width/height channel keys are mapped to tight constraints.
        if channel.keys.contains("width") {
            let value = Self.decodeDouble(channel["width"])
            if constraints == nil {
                constraints = CNViewConstraintsPayload()
            }
            constraints?.minWidth = value
            constraints?.maxWidth = value
        }

        if channel.keys.contains("height") {
            let value = Self.decodeDouble(channel["height"])
            if constraints == nil {
                constraints = CNViewConstraintsPayload()
            }
            constraints?.minHeight = value
            constraints?.maxHeight = value
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

        result["shrinkWrap"] = shrinkWrap

        if let constraints {
            result["constraints"] = constraints.toChannel()
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
        let shrinkWrapKey = "\(shrinkWrap)"
        let constraintsKey = constraints?.identityKey() ?? "nil"
        let tintKey = tint.map { "\($0)" } ?? "nil"
        let foregroundColorKey = foregroundColor.map { "\($0)" } ?? "nil"

        return [
            tagKey,
            paddingKey,
            controlSizeKey,
            enabledKey,
            shrinkWrapKey,
            constraintsKey,
            tintKey,
            foregroundColorKey,
        ].joined(separator: "|")
    }

    static func decodeBool(_ value: Any?) -> Bool? {
        if value is NSNull {
            return nil
        }
        return (value as? NSNumber)?.boolValue ?? value as? Bool
    }

    private static func decodeInt(_ value: Any?) -> Int? {
        if value is NSNull {
            return nil
        }
        return (value as? NSNumber)?.intValue ?? value as? Int
    }

    static func decodeDouble(_ value: Any?) -> Double? {
        if value is NSNull {
            return nil
        }
        if value is String {
            let stringValue = value as! String
            if stringValue == "infinity" {
                return Double.infinity
            } else if stringValue == "-infinity" {
                return -Double.infinity
            } else if stringValue == "nan" {
                return Double.nan
            } else if stringValue == "zero" {
                return Double.zero
            }
        }
        return (value as? NSNumber)?.doubleValue ?? value as? Double
    }

    private static func decodeString(_ value: Any?) -> String? {
        if value is NSNull {
            return nil
        }
        return value as? String
    }
}
