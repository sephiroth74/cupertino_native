import SwiftUI

final class CNImage2ViewModel: ObservableObject {
    @Published private(set) var payload: CNImage2Payload

    init(payload: CNImage2Payload) {
        self.payload = payload
    }

    func replace(with payload: CNImage2Payload) {
        NSLog("[CNImage2ViewModel_\(payload.viewDebugId)][Swift] Replacing payload with new payload: \(payload)")
        self.payload = payload
    }

    func applyPatch(_ patch: [String: Any]) {
        NSLog("[CNImage2ViewModel_\(payload.viewDebugId)][Swift] Applying patch: \(patch)")
        var next = payload
        next.applyPatch(patch)
        payload = next
    }
}
