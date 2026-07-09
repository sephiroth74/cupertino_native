import SwiftUI

struct CNBoxConstraintsPayload {
    let minWidth: CGFloat?
    let maxWidth: CGFloat?
    let minHeight: CGFloat?
    let maxHeight: CGFloat?

    var tightWidth: CGFloat? {
        minWidth == maxWidth ? minWidth : nil
    }

    var tightHeight: CGFloat? {
        minHeight == maxHeight ? minHeight : nil
    }

    static func fromChannel(_ channel: [String: Any]?) -> CNBoxConstraintsPayload? {
        guard let map = channel else {
            return nil
        }

        return CNBoxConstraintsPayload(
            minWidth: CNChannelDeserialization.decodeCGFloat(map["minWidth"]),
            maxWidth: CNChannelDeserialization.decodeCGFloat(map["maxWidth"]),
            minHeight: CNChannelDeserialization.decodeCGFloat(map["minHeight"]),
            maxHeight: CNChannelDeserialization.decodeCGFloat(map["maxHeight"]),
        )
    }

    func identityKey() -> String {
        [
            minWidth.map { String(describing: $0) } ?? "nil",
            maxWidth.map { String(describing: $0) } ?? "nil",
            minHeight.map { String(describing: $0) } ?? "nil",
            maxHeight.map { String(describing: $0) } ?? "nil",
        ].joined(separator: "|")
    }
}
