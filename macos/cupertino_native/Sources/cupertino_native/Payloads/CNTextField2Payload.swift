import SwiftUI

struct CNTextField2Payload: CNSharedPayloadFields {
    // Shared fields
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Any?
    var foregroundColor: Int?
    var help: String?

    // TextField-specific fields
    var text: String
    var selectionBase: Int?
    var selectionExtent: Int?
    var placeholder: String?
    var prompt: String?
    var textFieldStyle: String?
    var controlSize: String?
    var font: [String: Any]?
    var borderColor: Int?
    var borderWidth: Double?
    var autofocus: Bool
    var maxLength: Int?

    init(viewId: String) {
        viewDebugId = viewId
        debugLog = false
        shrink = false
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        help = nil
        text = ""
        selectionBase = nil
        selectionExtent = nil
        placeholder = nil
        prompt = nil
        textFieldStyle = "automatic"
        controlSize = "regular"
        font = nil
        borderColor = nil
        borderWidth = nil
        autofocus = false
        maxLength = nil
    }

    init?(channel: [String: Any], viewId: Int64) {
        let debugId = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: debugId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("text") {
            text = CNChannelDeserialization.decodeString(channel["text"]) ?? ""
        }

        if channel.keys.contains("selectionBase") {
            selectionBase = CNChannelDeserialization.decodeInt(channel["selectionBase"])
        }

        if channel.keys.contains("selectionExtent") {
            selectionExtent = CNChannelDeserialization.decodeInt(channel["selectionExtent"])
        }

        if channel.keys.contains("placeholder") {
            placeholder = CNChannelDeserialization.decodeString(channel["placeholder"])
        }

        if channel.keys.contains("prompt") {
            prompt = CNChannelDeserialization.decodeString(channel["prompt"])
        }

        if channel.keys.contains("textFieldStyle") {
            textFieldStyle = CNChannelDeserialization.decodeString(channel["textFieldStyle"])
        }

        if channel.keys.contains("controlSize") {
            controlSize = CNChannelDeserialization.decodeString(channel["controlSize"])
        }

        if channel.keys.contains("font") {
            font = channel["font"] as? [String: Any]
        }

        if channel.keys.contains("borderColor") {
            borderColor = CNChannelDeserialization.decodeInt(channel["borderColor"])
        }

        if channel.keys.contains("borderWidth") {
            borderWidth = CNChannelDeserialization.decodeDouble(channel["borderWidth"])
        }

        if let value = channel["autofocus"] as? Bool {
            autofocus = value
        }

        if channel.keys.contains("maxLength") {
            maxLength = CNChannelDeserialization.decodeInt(channel["maxLength"])
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(contentsOf: [
            textFieldStyle ?? "nil",
            controlSize ?? "nil",
        ])
        return parts.joined(separator: "|")
    }
}
