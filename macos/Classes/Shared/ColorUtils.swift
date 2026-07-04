import Cocoa
import SwiftUI

class ColorUtils {
    static func colorToArgb(_ color: NSColor) -> Int {
        let a = Int(color.alphaComponent * 255)
        let r = Int(color.redComponent * 255)
        let g = Int(color.greenComponent * 255)
        let b = Int(color.blueComponent * 255)
        return (a << 24) | (r << 16) | (g << 8) | b
    }

    static func colorFromARGB(_ argb: Int) -> NSColor {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
    }

    static func swiftUIColorFromARGB(_ argb: Int) -> Color {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
