import SwiftUI

struct CNToggle2Payload: CNSharedPayloadFields {
    // Shared fields
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Any?
    var foregroundColor: Int?
    var help: String?
    var overlay: [String: Any]?

    // Toggle-specific fields
    var isOn: Bool
    var enabled: Bool
    var toggleStyle: String?
    var controlSize: String?
    var content: [String: Any]?

    init(viewId: String) {
        viewDebugId = viewId
        debugLog = false
        shrink = true
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        help = nil
        overlay = nil
        isOn = false
        enabled = true
        toggleStyle = "automatic"
        controlSize = "regular"
        content = nil
    }

    init?(channel: [String: Any], viewId: Int64) {
        let debugId = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: debugId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("isOn") {
            isOn = CNChannelDeserialization.decodeBool(channel["isOn"]) ?? isOn
        }

        if channel.keys.contains("enabled") {
            enabled = CNChannelDeserialization.decodeBool(channel["enabled"]) ?? true
        }

        if channel.keys.contains("toggleStyle") {
            toggleStyle = CNChannelDeserialization.decodeString(channel["toggleStyle"])
        }

        if channel.keys.contains("controlSize") {
            controlSize = CNChannelDeserialization.decodeString(channel["controlSize"])
        }

        if channel.keys.contains("content") {
            content = channel["content"] as? [String: Any]
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(contentsOf: [
            toggleStyle ?? "nil",
            controlSize ?? "nil",
        ])
        return parts.joined(separator: "|")
    }
}
