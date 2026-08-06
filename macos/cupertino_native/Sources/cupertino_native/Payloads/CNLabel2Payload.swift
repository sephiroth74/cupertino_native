import Foundation

struct CNLabel2Payload: CNSharedPayloadFields {
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

    var title: [String: Any]?
    var image: [String: Any]?
    var font: [String: Any]?
    var labelStyle: String?
    var labelReservedIconWidth: Double?
    var labelIconToTitleSpacing: Double?

    init(viewId _: Int64) {
        viewDebugId = ""
        debugLog = false
        shrink = true
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        help = nil
        overlay = nil
        background = nil
        title = nil
        image = nil
        font = nil
        labelStyle = nil
        labelReservedIconWidth = nil
        labelIconToTitleSpacing = nil
    }

    init?(channel: [String: Any], viewId: Int64) {
        self.init(viewId: viewId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("title") {
            title = channel["title"] as? [String: Any]
        }

        if channel.keys.contains("image") {
            if channel["image"] is NSNull {
                image = nil
            } else {
                image = channel["image"] as? [String: Any]
            }
        }

        if channel.keys.contains("font") {
            if channel["font"] is NSNull {
                font = nil
            } else {
                font = channel["font"] as? [String: Any]
            }
        }

        if channel.keys.contains("labelStyle") {
            labelStyle = channel["labelStyle"] as? String
        }

        if channel.keys.contains("labelReservedIconWidth") {
            labelReservedIconWidth = CNChannelDeserialization.decodeDouble(channel["labelReservedIconWidth"])
        }

        if channel.keys.contains("labelIconToTitleSpacing") {
            labelIconToTitleSpacing = CNChannelDeserialization.decodeDouble(channel["labelIconToTitleSpacing"])
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(title.map { String(describing: $0) } ?? "nil")
        parts.append(image.map { String(describing: $0) } ?? "nil")
        parts.append(font.map { String(describing: $0) } ?? "nil")
        parts.append(labelStyle ?? "automatic")
        parts.append(labelReservedIconWidth.map { String($0) } ?? "nil")
        parts.append(labelIconToTitleSpacing.map { String($0) } ?? "nil")
        return parts.joined(separator: "|")
    }
}
