import Foundation

struct CNButton2Payload: CNSharedPayloadFields {
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Any?
    var foregroundColor: Int?
    var enabled: Bool?

    var children: [[String: Any]]
    var buttonStyle: String?
    var role: String?
    var controlSize: String?
    var labelStyle: String?

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
        labelStyle = nil
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

        if channel.keys.contains("labelStyle") {
            labelStyle = channel["labelStyle"] as? String
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
        parts.append(labelStyle ?? "nil")
        parts.append(enabled.map { String($0) } ?? "nil")
        return parts.joined(separator: "|")
    }
}
