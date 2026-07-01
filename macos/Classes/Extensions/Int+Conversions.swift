import Swift
import SwiftUI

extension Int {
    func toARGB() -> Color {
        let a = CGFloat((self >> 24) & 0xFF) / 255.0
        let r = CGFloat((self >> 16) & 0xFF) / 255.0
        let g = CGFloat((self >> 8) & 0xFF) / 255.0
        let b = CGFloat(self & 0xFF) / 255.0
        return Color(nsColor: NSColor(srgbRed: r, green: g, blue: b, alpha: a))
    }
}
