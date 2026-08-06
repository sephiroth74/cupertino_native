import SwiftUI

struct CNText2Payload: CNSharedPayloadFields {
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
    var background: [String: Any]?

    // Text-specific fields
    var text: String
    var font: [String: Any]?
    var lineLimit: Int?
    var lineLimitReservesSpace: Bool?
    var textScale: String?
    var truncationMode: String?

    init(viewId: String) {
        viewDebugId = viewId
        debugLog = false
        shrink = false
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        help = nil
        overlay = nil
        background = nil
        text = ""
        font = nil
        lineLimit = nil
        lineLimitReservesSpace = nil
        textScale = nil
        truncationMode = nil
    }

    init?(channel: [String: Any], viewId: Int64) {
        guard channel["text"] != nil else {
            return nil
        }
        let debugId = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: debugId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("text") {
            text = CNChannelDeserialization.decodeString(channel["text"]) ?? ""
        }

        if channel.keys.contains("font") {
            if channel["font"] is NSNull {
                font = nil
            } else if let fontPatch = channel["font"] as? [String: Any] {
                if let current = font {
                    font = DeserializerUtils.deepMerge(current, with: fontPatch)
                } else {
                    font = fontPatch
                }
            } else {
                font = nil
            }
        }

        if channel.keys.contains("lineLimit") {
            lineLimit = CNChannelDeserialization.decodeInt(channel["lineLimit"])
        }

        if channel.keys.contains("lineLimitReservesSpace") {
            lineLimitReservesSpace = CNChannelDeserialization.decodeBool(channel["lineLimitReservesSpace"])
        }

        if channel.keys.contains("textScale") {
            textScale = CNChannelDeserialization.decodeString(channel["textScale"])
        }

        if channel.keys.contains("truncationMode") {
            truncationMode = CNChannelDeserialization.decodeString(channel["truncationMode"])
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(contentsOf: [
            text,
            font.map { String(describing: $0) } ?? "nil",
            lineLimit.map { String($0) } ?? "nil",
            lineLimitReservesSpace.map { String($0) } ?? "nil",
            textScale ?? "nil",
            truncationMode ?? "nil",
        ])
        return parts.joined(separator: "|")
    }
}
