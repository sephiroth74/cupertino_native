import SwiftUI

struct CNImage2Payload: CNSharedPayloadFields {
    // Shared fields
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Any?
    var foregroundColor: Int?

    // Image-specific fields
    var systemSymbolName: String
    var font: [String: Any]?
    var symbolRenderingMode: String?
    var symbolColorRenderingMode: String?
    var foregroundStyleColors: [Int]

    init(viewId: String) {
        viewDebugId = viewId
        debugLog = false
        shrink = false
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        systemSymbolName = "questionmark.circle"
        font = nil
        symbolRenderingMode = nil
        symbolColorRenderingMode = nil
        foregroundStyleColors = []
    }

    init?(channel: [String: Any], viewId: Int64) {
        guard channel["systemSymbolName"] != nil else {
            return nil
        }
        let debugId = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: debugId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("systemSymbolName"),
           let symbol = channel["systemSymbolName"] as? String,
           !symbol.isEmpty
        {
            systemSymbolName = symbol
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

        if channel.keys.contains("symbolRenderingMode") {
            symbolRenderingMode = CNChannelDeserialization.decodeString(channel["symbolRenderingMode"])
        }

        if channel.keys.contains("symbolColorRenderingMode") {
            symbolColorRenderingMode = CNChannelDeserialization.decodeString(channel["symbolColorRenderingMode"])
        }

        if channel.keys.contains("foregroundStyleColors") {
            if channel["foregroundStyleColors"] is NSNull {
                foregroundStyleColors = []
            } else if let rawColors = channel["foregroundStyleColors"] as? [NSNumber] {
                foregroundStyleColors = rawColors.map(\.intValue)
            } else if let rawColors = channel["foregroundStyleColors"] as? [Int] {
                foregroundStyleColors = rawColors
            } else {
                foregroundStyleColors = []
            }
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(contentsOf: [
            systemSymbolName,
            font.map { String(describing: $0) } ?? "nil",
            symbolRenderingMode ?? "nil",
            symbolColorRenderingMode ?? "nil",
            foregroundStyleColors.map { String(describing: $0) }.joined(separator: ","),
        ])
        return parts.joined(separator: "|")
    }
}
