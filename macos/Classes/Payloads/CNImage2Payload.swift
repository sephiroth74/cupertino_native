import SwiftUI

struct CNImage2Payload: CNChannelDeserializable {
    var systemSymbolName: String
    var viewDebugId: String
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var font: [String: Any]?
    var tint: Int?
    var foregroundColor: Int?
    var symbolRenderingMode: String?
    var symbolColorRenderingMode: String?
    var foregroundStyleColors: [Int]

    init(viewId: String) {
        systemSymbolName = "questionmark.circle"
        viewDebugId = viewId
        font = nil
        shrink = false
        constraints = nil
        tint = nil
        foregroundColor = nil
        symbolRenderingMode = nil
        symbolColorRenderingMode = nil
        foregroundStyleColors = []
        paddings = nil
    }

    init?(channel: [String: Any], viewId: Int64) {
        guard channel["systemSymbolName"] != nil else {
            return nil
        }

        let viewDebugId: String = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: viewDebugId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        NSLog("[CNImage2Payload_\(viewDebugId)][Swift] Applying patch: \(channel)")
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

        if channel.keys.contains("shrink") {
            shrink = CNChannelDeserialization.decodeBool(channel["shrink"]) ?? false
        }

        if channel.keys.contains("constraints") {
            if channel["constraints"] is NSNull {
                constraints = nil
            } else if let constraintsMap = channel["constraints"] as? [String: Any] {
                constraints = CNBoxConstraintsPayload.fromChannel(constraintsMap)
            } else {
                constraints = nil
            }
        }

        if channel.keys.contains("paddings") {
            if channel["paddings"] is NSNull {
                paddings = nil
            } else if let paddingsMap = channel["paddings"] as? [String: Any] {
                paddings = CNPaddingsPayload.fromChannel(paddingsMap)
            } else {
                paddings = nil
            }
        }

        if channel.keys.contains("tint") {
            tint = CNChannelDeserialization.decodeInt(channel["tint"])
        }

        if channel.keys.contains("foregroundColor") {
            foregroundColor = CNChannelDeserialization.decodeInt(channel["foregroundColor"])
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
        let fontKey = font.map { String(describing: $0) } ?? "nil"
        let tintKey = tint.map { String(describing: $0) } ?? "nil"
        let foregroundColorKey = foregroundColor.map { String(describing: $0) } ?? "nil"
        let constraintsKey = constraints?.identityKey() ?? "nil"
        let shrinkKey = String(describing: shrink)
        let symbolRenderingModeKey = symbolRenderingMode ?? "nil"
        let symbolColorRenderingModeKey = symbolColorRenderingMode ?? "nil"
        let foregroundStyleColorsKey = foregroundStyleColors.map { String(describing: $0) }.joined(separator: ",")
        let paddingsKey = paddings?.identityKey() ?? "nil"
        return [
            viewDebugId,
            systemSymbolName,
            fontKey,
            tintKey,
            foregroundColorKey,
            constraintsKey,
            shrinkKey,
            symbolRenderingModeKey,
            symbolColorRenderingModeKey,
            foregroundStyleColorsKey,
            paddingsKey,
        ].joined(separator: "|")
    }
}
