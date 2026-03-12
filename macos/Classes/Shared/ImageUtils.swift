import Cocoa

extension NSImage {
    func tinted(with color: NSColor) -> NSImage {
        let img = NSImage(size: size)
        img.lockFocus()
        let rect = NSRect(origin: .zero, size: size)
        color.set()
        rect.fill()
        draw(in: rect, from: .zero, operation: .destinationIn, fraction: 1.0)
        img.unlockFocus()
        return img
    }
}
