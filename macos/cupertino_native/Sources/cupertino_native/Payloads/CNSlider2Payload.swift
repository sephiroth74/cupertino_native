import SwiftUI

struct CNSlider2Payload: CNSharedPayloadFields {
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

    // Slider-specific fields
    var value: Double
    var min: Double
    var max: Double
    var step: Double?
    var controlSize: String?
    var minimumValueLabel: String?
    var maximumValueLabel: String?
    var enabled: Bool
    var ticks: [CNSliderTickPayload]?

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
        value = 0.0
        min = 0.0
        max = 1.0
        step = nil
        controlSize = "regular"
        minimumValueLabel = nil
        maximumValueLabel = nil
        enabled = true
        ticks = nil
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

        if channel.keys.contains("min") {
            min = CNChannelDeserialization.decodeDouble(channel["min"]) ?? min
        }

        if channel.keys.contains("max") {
            max = CNChannelDeserialization.decodeDouble(channel["max"]) ?? max
        }

        if min >= max {
            max = min + 1.0
        }

        if channel.keys.contains("value") {
            if let rawValue = CNChannelDeserialization.decodeDouble(channel["value"]) {
                value = Swift.min(Swift.max(rawValue, min), max)
            }
        } else {
            // Re-clamp value after range change
            value = Swift.min(Swift.max(value, min), max)
        }

        if channel.keys.contains("step") {
            step = CNChannelDeserialization.decodeDouble(channel["step"])
        }

        if channel.keys.contains("controlSize") {
            controlSize = CNChannelDeserialization.decodeString(channel["controlSize"])
        }

        if channel.keys.contains("minimumValueLabel") {
            minimumValueLabel = CNChannelDeserialization.decodeString(channel["minimumValueLabel"])
        }

        if channel.keys.contains("maximumValueLabel") {
            maximumValueLabel = CNChannelDeserialization.decodeString(channel["maximumValueLabel"])
        }

        if channel.keys.contains("enabled") {
            enabled = CNChannelDeserialization.decodeBool(channel["enabled"]) ?? true
        }

        if channel.keys.contains("ticks") {
            if channel["ticks"] is NSNull || channel["ticks"] == nil {
                ticks = nil
            } else if let ticksList = channel["ticks"] as? [[String: Any]] {
                ticks = ticksList.compactMap { CNSliderTickPayload.fromChannel($0) }
            } else {
                ticks = nil
            }
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(contentsOf: [
            String(min),
            String(max),
            step.map { String($0) } ?? "nil",
            controlSize ?? "nil",
            ticks.map { t in t.map { "\($0.value):\($0.label ?? "")" }.joined(separator: ",") } ?? "nil",
        ])
        return parts.joined(separator: "|")
    }
}

struct CNSliderTickPayload {
    var value: Double
    var label: String?

    static func fromChannel(_ dict: [String: Any]) -> CNSliderTickPayload? {
        guard let value = CNChannelDeserialization.decodeDouble(dict["value"]) else {
            return nil
        }
        let label = CNChannelDeserialization.decodeString(dict["label"])
        return CNSliderTickPayload(value: value, label: label)
    }
}
