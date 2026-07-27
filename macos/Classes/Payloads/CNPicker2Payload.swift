import Foundation

struct CNPicker2Payload: CNSharedPayloadFields {
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Any?
    var foregroundColor: Int?
    var help: String?
    var enabled: Bool?

    var children: [[String: Any]]
    var selection: String
    var label: [[String: Any]]?
    var pickerStyle: String?
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
        help = nil
        children = []
        selection = ""
        label = nil
        pickerStyle = nil
        controlSize = nil
        font = nil
        enabled = nil
    }

    init?(channel: [String: Any], viewId: Int64) {
        self.init(viewId: viewId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("children") {
            if let list = channel["children"] as? [[String: Any]] {
                children = list
            }
        }

        if channel.keys.contains("selection") {
            selection = channel["selection"] as? String ?? ""
        }

        if channel.keys.contains("label") {
            if channel["label"] is NSNull {
                label = nil
            } else {
                label = channel["label"] as? [[String: Any]]
            }
        }

        if channel.keys.contains("pickerStyle") {
            pickerStyle = channel["pickerStyle"] as? String
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

        if channel.keys.contains("enabled") {
            enabled = channel["enabled"] as? Bool
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(String(describing: children))
        parts.append(selection)
        parts.append(String(describing: label))
        parts.append(pickerStyle ?? "automatic")
        parts.append(controlSize ?? "nil")
        parts.append(font.map { String(describing: $0) } ?? "nil")
        parts.append(enabled.map { String(describing: $0) } ?? "nil")
        return parts.joined(separator: "|")
    }
}
