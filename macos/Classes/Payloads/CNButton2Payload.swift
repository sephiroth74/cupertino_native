import Foundation

struct CNButton2Payload: CNSharedPayloadFields {
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Int?
    var foregroundColor: Int?
    var enabled: Bool?

    var children: [[String: Any]]
    var buttonStyle: String?
    var role: String?
    var controlSize: String?
    var font: [String: Any]?
    var labelStyle: String?
    var labelReservedIconWidth: Double?
    var labelIconToTitleSpacing: Double?

    init(viewId _: Int64) {
        viewDebugId = ""
        debugLog = false
        shrink = true
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        children = []
        buttonStyle = nil
        role = nil
        controlSize = nil
        font = nil
        labelStyle = nil
        labelReservedIconWidth = nil
        labelIconToTitleSpacing = nil
        enabled = nil
    }

    init?(channel: [String: Any], viewId: Int64) {
        self.init(viewId: viewId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("children") {
            if let list = channel["children"] as? [[String: Any]] {
                children = list
            }
        }

        if channel.keys.contains("buttonStyle") {
            buttonStyle = channel["buttonStyle"] as? String
        }

        if channel.keys.contains("role") {
            role = channel["role"] as? String
        }

        if channel.keys.contains("controlSize") {
            controlSize = channel["controlSize"] as? String
        }

        if channel.keys.contains("font") {
            if channel["font"] is NSNull {
                font = nil
            } else {
                font = channel["font"] as? [String: Any]
            }
        }

        if channel.keys.contains("labelStyle") {
            labelStyle = channel["labelStyle"] as? String
        }

        if channel.keys.contains("labelReservedIconWidth") {
            labelReservedIconWidth = CNChannelDeserialization.decodeDouble(channel["labelReservedIconWidth"])
        }

        if channel.keys.contains("labelIconToTitleSpacing") {
            labelIconToTitleSpacing = CNChannelDeserialization.decodeDouble(channel["labelIconToTitleSpacing"])
        }

        if channel.keys.contains("enabled") {
            enabled = channel["enabled"] as? Bool
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(String(describing: children))
        parts.append(buttonStyle ?? "automatic")
        parts.append(role ?? "none")
        parts.append(controlSize ?? "nil")
        parts.append(font.map { String(describing: $0) } ?? "nil")
        parts.append(labelStyle ?? "nil")
        parts.append(labelReservedIconWidth.map { String($0) } ?? "nil")
        parts.append(labelIconToTitleSpacing.map { String($0) } ?? "nil")
        parts.append(enabled.map { String($0) } ?? "nil")
        return parts.joined(separator: "|")
    }
}
