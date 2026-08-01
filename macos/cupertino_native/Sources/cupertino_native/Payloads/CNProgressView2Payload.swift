import SwiftUI

struct CNProgressView2Payload: CNSharedPayloadFields {
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

    // ProgressView-specific fields
    var style: String?
    var controlSize: String?
    var value: Double?
    var total: Double?

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
        style = "linear"
        controlSize = "regular"
        value = nil
        total = 1.0
    }

    init?(channel: [String: Any], viewId: Int64) {
        let debugId = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: debugId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("style") {
            style = CNChannelDeserialization.decodeString(channel["style"])
        }

        if channel.keys.contains("controlSize") {
            controlSize = CNChannelDeserialization.decodeString(channel["controlSize"])
        }

        if channel.keys.contains("value") {
            value = CNChannelDeserialization.decodeDouble(channel["value"])
        }

        if channel.keys.contains("total") {
            total = CNChannelDeserialization.decodeDouble(channel["total"])
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(contentsOf: [
            style ?? "nil",
            controlSize ?? "nil",
            value.map { String($0) } ?? "nil",
            total.map { String($0) } ?? "nil",
        ])
        return parts.joined(separator: "|")
    }
}
