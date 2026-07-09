import SwiftUI

struct CNPaddingsPayload: Identifiable {
    let top: CGFloat
    let leading: CGFloat
    let bottom: CGFloat
    let trailing: CGFloat

    static func fromChannel(_ channel: [String: Any]?) -> CNPaddingsPayload? {
        guard let map = channel else {
            return nil
        }

        return CNPaddingsPayload(
            top: CNChannelDeserialization.decodeCGFloat(map["top"]) ?? 0,
            leading: CNChannelDeserialization.decodeCGFloat(map["leading"]) ?? 0,
            bottom: CNChannelDeserialization.decodeCGFloat(map["bottom"]) ?? 0,
            trailing: CNChannelDeserialization.decodeCGFloat(map["trailing"]) ?? 0,
        )
    }

    func identityKey() -> String {
        [
            String(describing: top),
            String(describing: leading),
            String(describing: bottom),
            String(describing: trailing),
        ].joined(separator: "|")
    }
}
