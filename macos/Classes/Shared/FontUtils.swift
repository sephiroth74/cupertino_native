import Cocoa

class FontUtils {
    static func fontFromDictionary(_ dict: [String: Any]) -> NSFont? {
        guard
            let kind = dict["kind"] as? String,
            let sizeDict = dict["size"] as? [String: Any]
        else {
            return nil
        }

        let size = sizeFromDictionary(sizeDict)
        let weight = weightFromString(dict["weight"] as? String)

        switch kind {
        case "system":
            return NSFont.systemFont(ofSize: size, weight: weight)
        case "boldSystem":
            return NSFont.boldSystemFont(ofSize: size)
        case "monospacedSystem":
            return NSFont.monospacedSystemFont(ofSize: size, weight: weight)
        case "monospacedDigitSystem":
            return NSFont.monospacedDigitSystemFont(ofSize: size, weight: weight)
        case "user":
            return NSFont.userFont(ofSize: size)
        case "userFixedPitch":
            return NSFont.userFixedPitchFont(ofSize: size)
        case "menu":
            return NSFont.menuFont(ofSize: size)
        case "menuBar":
            return NSFont.menuBarFont(ofSize: size)
        case "message":
            return NSFont.messageFont(ofSize: size)
        case "palette":
            return NSFont.paletteFont(ofSize: size)
        case "titleBar":
            return NSFont.titleBarFont(ofSize: size)
        case "toolTips":
            return NSFont.toolTipsFont(ofSize: size)
        case "controlContent":
            return NSFont.controlContentFont(ofSize: size)
        case "label":
            return NSFont.labelFont(ofSize: size)
        case "named":
            guard let name = dict["name"] as? String else { return nil }
            return NSFont(name: name, size: size)
        default:
            return nil
        }
    }

    private static func sizeFromDictionary(_ dict: [String: Any]) -> CGFloat {
        if let preset = dict["preset"] as? String {
            switch preset {
            case "system":
                return NSFont.systemFontSize
            case "smallSystem":
                return NSFont.smallSystemFontSize
            case "label":
                return NSFont.labelFontSize
            default:
                break
            }
        }

        if let value = dict["points"] as? NSNumber {
            return CGFloat(truncating: value)
        }

        return NSFont.systemFontSize
    }

    private static func weightFromString(_ value: String?) -> NSFont.Weight {
        switch value {
        case "ultraLight":
            return .ultraLight
        case "thin":
            return .thin
        case "light":
            return .light
        case "medium":
            return .medium
        case "semibold":
            return .semibold
        case "bold":
            return .bold
        case "heavy":
            return .heavy
        case "black":
            return .black
        case "regular", .none:
            return .regular
        default:
            return .regular
        }
    }
}
