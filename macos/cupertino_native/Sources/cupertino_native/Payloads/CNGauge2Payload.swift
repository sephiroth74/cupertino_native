import SwiftUI

struct CNGauge2Payload: CNSharedPayloadFields {
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Any?
    var foregroundColor: Int?
    var help: String?
    var overlay: [String: Any]?
    var background: [String: Any]?

    var value: Double
    var min: Double
    var max: Double
    var gaugeStyle: String?
    var controlSize: String?
    var label: [[String: Any]]?
    var currentValueLabel: [[String: Any]]?
    var minimumValueLabel: [[String: Any]]?
    var maximumValueLabel: [[String: Any]]?

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
        background = nil
        value = 0
        min = 0
        max = 1
        gaugeStyle = "automatic"
        controlSize = "regular"
        label = nil
        currentValueLabel = nil
        minimumValueLabel = nil
        maximumValueLabel = nil
    }

    init?(channel: [String: Any], viewId: Int64) {
        let debugId = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: debugId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("value") {
            value = CNChannelDeserialization.decodeDouble(channel["value"]) ?? 0
        }

        if channel.keys.contains("min") {
            min = CNChannelDeserialization.decodeDouble(channel["min"]) ?? 0
        }

        if channel.keys.contains("max") {
            max = CNChannelDeserialization.decodeDouble(channel["max"]) ?? 1
        }

        if channel.keys.contains("gaugeStyle") {
            gaugeStyle = CNChannelDeserialization.decodeString(channel["gaugeStyle"])
        }

        if channel.keys.contains("controlSize") {
            controlSize = CNChannelDeserialization.decodeString(channel["controlSize"])
        }

        if channel.keys.contains("label") {
            label = channel["label"] as? [[String: Any]]
        }

        if channel.keys.contains("currentValueLabel") {
            currentValueLabel = channel["currentValueLabel"] as? [[String: Any]]
        }

        if channel.keys.contains("minimumValueLabel") {
            minimumValueLabel = channel["minimumValueLabel"] as? [[String: Any]]
        }

        if channel.keys.contains("maximumValueLabel") {
            maximumValueLabel = channel["maximumValueLabel"] as? [[String: Any]]
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(gaugeStyle ?? "automatic")
        return parts.joined(separator: "|")
    }
}
