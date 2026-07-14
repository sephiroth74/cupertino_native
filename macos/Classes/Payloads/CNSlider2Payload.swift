import SwiftUI

struct CNSlider2Payload: CNSharedPayloadFields {
    // Shared fields
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Int?
    var foregroundColor: Int?

    // Slider-specific fields
    var value: Double
    var min: Double
    var max: Double
    var step: Double?
    var controlSize: String?

    init(viewId: String) {
        viewDebugId = viewId
        debugLog = false
        shrink = true
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        value = 0.0
        min = 0.0
        max = 1.0
        step = nil
        controlSize = "regular"
    }

    init?(channel: [String: Any], viewId: Int64) {
        let debugId = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: debugId)
        applyPatch(channel)
        if min >= max {
            return nil
        }
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("value") {
            if let rawValue = CNChannelDeserialization.decodeDouble(channel["value"]) {
                value = Swift.min(Swift.max(rawValue, min), max)
            }
        }

        if channel.keys.contains("min") {
            min = CNChannelDeserialization.decodeDouble(channel["min"]) ?? min
        }

        if channel.keys.contains("max") {
            max = CNChannelDeserialization.decodeDouble(channel["max"]) ?? max
        }

        if min >= max {
            max = min + 1.0
        }

        // Re-clamp value after range change
        value = Swift.min(Swift.max(value, min), max)

        if channel.keys.contains("step") {
            step = CNChannelDeserialization.decodeDouble(channel["step"])
        }

        if channel.keys.contains("controlSize") {
            controlSize = CNChannelDeserialization.decodeString(channel["controlSize"])
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(contentsOf: [
            String(min),
            String(max),
            step.map { String($0) } ?? "nil",
            controlSize ?? "nil",
        ])
        return parts.joined(separator: "|")
    }
}
