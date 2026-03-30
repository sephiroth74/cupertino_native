import Cocoa

final class CupertinoImageDeserializer {
    static func deserialize(dict: [String: Any]) -> NSImage? {
        guard let systemSymbolName = dict["systemSymbolName"] as? String else {
            return nil
        }

        let baseImage = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil)
        guard let symbolConfig = dict["symbolConfiguration"] as? [String: Any],
            let type = symbolConfig["type"] as? String
        else {
            return baseImage
        }

        switch type {
        case "hierarchical":
            if let value = symbolConfig["color"] as? NSNumber {
                let color = colorFromARGB(value.intValue)
                return baseImage?.withSymbolConfiguration(.init(hierarchicalColor: color))
            }
        case "monochrome":
            if let value = symbolConfig["color"] as? NSNumber {
                return tint(image: baseImage, with: colorFromARGB(value.intValue))
            }
            return baseImage?.withSymbolConfiguration(.preferringMonochrome())
        case "palette":
            if let colors = symbolConfig["colors"] as? [NSNumber], !colors.isEmpty {
                let nsColors = colors.map { colorFromARGB($0.intValue) }
                return baseImage?.withSymbolConfiguration(.init(paletteColors: nsColors))
            }
        case "multicolor":
            return baseImage?.withSymbolConfiguration(.preferringMulticolor())
        default:
            break
        }

        return baseImage
    }

    static func deserialize(jsonString: String) -> NSImage? {
        do {
            if let imageDict = try JSONSerialization.jsonObject(
                with: Data(jsonString.utf8), options: []) as? [String: Any]
            {
                return deserialize(dict: imageDict)
            }
        } catch {
            NSLog("Error deserializing image JSON string: \(error)")
        }
        return nil
    }

    private static func colorFromARGB(_ argb: Int) -> NSColor {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
    }

    private static func tint(image: NSImage?, with color: NSColor) -> NSImage? {
        guard let image else { return nil }
        let tinted = NSImage(size: image.size)
        tinted.lockFocus()
        let rect = NSRect(origin: .zero, size: image.size)
        color.set()
        rect.fill()
        image.draw(in: rect, from: .zero, operation: .destinationIn, fraction: 1.0)
        tinted.unlockFocus()
        return tinted
    }
}
