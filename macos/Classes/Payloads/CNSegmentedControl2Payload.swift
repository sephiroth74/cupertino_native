import Foundation

struct CNSegmentedControl2Payload: CNSharedPayloadFields {
    var viewDebugId: String
    var debugLog: Bool
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var paddings: CNPaddingsPayload?
    var tint: Any?
    var foregroundColor: Int?

    var labels: [String]?
    var symbols: [String]?
    var selectedIndex: Int
    var enabled: Bool

    init(viewId _: Int64) {
        viewDebugId = ""
        debugLog = false
        shrink = true
        constraints = nil
        paddings = nil
        tint = nil
        foregroundColor = nil
        labels = nil
        symbols = nil
        selectedIndex = 0
        enabled = true
    }

    init?(channel: [String: Any], viewId: Int64) {
        self.init(viewId: viewId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        applySharedPatch(channel)

        if channel.keys.contains("labels") {
            if channel["labels"] is NSNull {
                labels = nil
            } else {
                labels = channel["labels"] as? [String]
            }
        }

        if channel.keys.contains("symbols") {
            if channel["symbols"] is NSNull {
                symbols = nil
            } else {
                symbols = channel["symbols"] as? [String]
            }
        }

        if let idx = channel["selectedIndex"] as? NSNumber {
            selectedIndex = idx.intValue
        }

        if let e = channel["enabled"] as? NSNumber {
            enabled = e.boolValue
        }
    }

    func identityKey() -> String {
        var parts = sharedIdentityKey()
        parts.append(labels?.joined(separator: ",") ?? "nil")
        parts.append(symbols?.joined(separator: ",") ?? "nil")
        parts.append(String(selectedIndex))
        parts.append(String(enabled))
        return parts.joined(separator: "|")
    }
}
