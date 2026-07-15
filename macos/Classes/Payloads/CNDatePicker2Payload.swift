import SwiftUI

struct CNDatePicker2Payload: CNSharedPayloadFields {
    // Shared fields
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Int?
    var foregroundColor: Int?

    // DatePicker-specific fields
    var selection: Double?
    var displayedComponents: [String]?
    var datePickerStyle: String?
    var controlSize: String?
    var label: String?
    var minDate: Double?
    var maxDate: Double?
    var enabled: Bool

    init(viewId: String) {
        viewDebugId = viewId
        debugLog = false
        shrink = true
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        selection = nil
        displayedComponents = ["date"]
        datePickerStyle = "automatic"
        controlSize = "regular"
        label = nil
        minDate = nil
        maxDate = nil
        enabled = true
    }

    init?(channel: [String: Any], viewId: Int64) {
        let debugId = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: debugId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("selection") {
            selection = CNChannelDeserialization.decodeDouble(channel["selection"])
        }

        if channel.keys.contains("displayedComponents") {
            if let list = channel["displayedComponents"] as? [String] {
                displayedComponents = list
            } else {
                displayedComponents = nil
            }
        }

        if channel.keys.contains("datePickerStyle") {
            datePickerStyle = CNChannelDeserialization.decodeString(channel["datePickerStyle"])
        }

        if channel.keys.contains("controlSize") {
            controlSize = CNChannelDeserialization.decodeString(channel["controlSize"])
        }

        if channel.keys.contains("label") {
            label = CNChannelDeserialization.decodeString(channel["label"])
        }

        if channel.keys.contains("minDate") {
            minDate = CNChannelDeserialization.decodeDouble(channel["minDate"])
        }

        if channel.keys.contains("maxDate") {
            maxDate = CNChannelDeserialization.decodeDouble(channel["maxDate"])
        }

        if channel.keys.contains("enabled") {
            enabled = CNChannelDeserialization.decodeBool(channel["enabled"]) ?? true
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(contentsOf: [
            datePickerStyle ?? "nil",
            controlSize ?? "nil",
            displayedComponents?.joined(separator: ",") ?? "nil",
            label ?? "nil",
        ])
        return parts.joined(separator: "|")
    }
}
