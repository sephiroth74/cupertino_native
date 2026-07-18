import Foundation

struct CNMenu2Payload: CNSharedPayloadFields {
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Int?
    var foregroundColor: Int?
    var enabled: Bool?

    var items: [[String: Any]]
    var label: [[String: Any]]
    var primaryActionTag: String?
    var menuStyle: String?
    var controlSize: String?
    var font: [String: Any]?

    init(viewId _: Int64) {
        viewDebugId = ""
        debugLog = false
        shrink = true
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        enabled = nil
        items = []
        label = []
        primaryActionTag = nil
        menuStyle = nil
        controlSize = nil
        font = nil
    }

    init?(channel: [String: Any], viewId: Int64) {
        self.init(viewId: viewId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("items") {
            if let list = channel["items"] as? [[String: Any]] {
                items = list
            }
        }

        if channel.keys.contains("enabled") {
            if channel["enabled"] is NSNull {
                enabled = nil
            } else {
                enabled = channel["enabled"] as? Bool
            }
        }

        if channel.keys.contains("label") {
            if let list = channel["label"] as? [[String: Any]] {
                label = list
            }
        }

        if channel.keys.contains("primaryActionTag") {
            if channel["primaryActionTag"] is NSNull {
                primaryActionTag = nil
            } else {
                primaryActionTag = channel["primaryActionTag"] as? String
            }
        }

        if channel.keys.contains("menuStyle") {
            menuStyle = channel["menuStyle"] as? String
        }

        if channel.keys.contains("controlSize") {
            controlSize = channel["controlSize"] as? String
        }

        if channel.keys.contains("font") {
            if channel["font"] is NSNull {
                font = nil
            } else {
                font = channel["font"] as? [String: Any]
            }
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(String(describing: items))
        parts.append(String(describing: label))
        parts.append(primaryActionTag ?? "nil")
        parts.append(menuStyle ?? "automatic")
        parts.append(controlSize ?? "nil")
        parts.append(font.map { String(describing: $0) } ?? "nil")
        return parts.joined(separator: "|")
    }
}
