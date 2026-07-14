import SwiftUI

/// Generic observable view model for any CN widget payload.
/// Holds a `@Published` payload and forwards patch/replace operations.
final class CNViewModel<P: CNChannelDeserializable>: ObservableObject {
    @Published var payload: P

    init(payload: P) {
        self.payload = payload
    }

    func replace(with payload: P) {
        self.payload = payload
    }

    func applyPatch(_ patch: [String: Any]) {
        var next = payload
        next.applyPatch(patch)
        payload = next
    }
}
