import SwiftUI

/// Protocol for payloads that carry the standard shared fields
/// (shrink, constraints, paddings, tint, foregroundColor, viewDebugId).
///
/// Conforming types get `applySharedPatch(_:)` and `sharedIdentityKey()` for free.
protocol CNSharedPayloadFields: CNChannelDeserializable {
    var viewDebugId: String { get set }
    var debugLog: Bool { get set }
    var shrink: Bool { get set }
    var constraints: CNBoxConstraintsPayload? { get set }
    var paddings: CNPaddingsPayload? { get set }
    var tint: Any? { get set }
    var foregroundColor: Int? { get set }
    var help: String? { get set }
    var overlay: [String: Any]? { get set }
}

extension CNSharedPayloadFields {
    /// Decodes the shared fields from a channel dictionary.
    /// Call this from your payload's `applyPatch(_:)` implementation.
    mutating func applySharedPatch(_ channel: [String: Any]) {
        if channel.keys.contains("debugLog") {
            debugLog = CNChannelDeserialization.decodeBool(channel["debugLog"]) ?? false
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
            if let tintInt = CNChannelDeserialization.decodeInt(channel["tint"]) {
                tint = tintInt
            } else if let tintDict = channel["tint"] as? [String: Any] {
                tint = tintDict
            } else {
                tint = nil
            }
        }

        if channel.keys.contains("foregroundColor") {
            foregroundColor = CNChannelDeserialization.decodeInt(channel["foregroundColor"])
        }

        if channel.keys.contains("help") {
            help = channel["help"] as? String
        }

        if channel.keys.contains("overlay") {
            overlay = channel["overlay"] as? [String: Any]
        }
    }

    /// Returns the identity key components for the shared fields.
    func sharedIdentityKey() -> [String] {
        let tintKey = if let tintInt = tint as? Int {
            String(describing: tintInt)
        } else if let tintDict = tint as? [String: Any] {
            String(describing: tintDict)
        } else {
            "nil"
        }
        return [
            viewDebugId,
            String(describing: shrink),
            constraints?.identityKey() ?? "nil",
            paddings?.identityKey() ?? "nil",
            tintKey,
            foregroundColor.map { String(describing: $0) } ?? "nil",
            help ?? "nil",
            overlay.map { String(describing: $0) } ?? "nil",
        ]
    }
}
