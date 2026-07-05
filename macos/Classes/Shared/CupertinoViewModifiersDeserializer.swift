import Foundation
import SwiftUI

struct CNViewModifiersPayload {
    var tag: AnyHashable?
    var padding: [String: Any]?
    var controlSize: String?
    var enabled: Bool?
    var tint: Int?
    var foregroundColor: Int?
    var width: Double?
    var height: Double?

    init() {}

    init(channel: [String: Any]) {
        self.init()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        tag = CNViewTag.parse(from: channel) ?? tag

        if let paddingValue = channel["padding"] as? [String: Any] {
            padding = paddingValue
        }

        if let controlSizeValue = channel["controlSize"] as? String {
            controlSize = controlSizeValue
        }

        if let enabledValue = (channel["enabled"] as? NSNumber)?.boolValue ?? channel["enabled"] as? Bool {
            enabled = enabledValue
        }

        if let widthValue = (channel["width"] as? NSNumber)?.doubleValue ?? channel["width"] as? Double {
            width = widthValue
        }

        if let heightValue = (channel["height"] as? NSNumber)?.doubleValue ?? channel["height"] as? Double {
            height = heightValue
        }

        if let tintValue = (channel["tint"] as? NSNumber)?.intValue ?? channel["tint"] as? Int {
            tint = tintValue
        }

        if let foregroundValue = (channel["foregroundColor"] as? NSNumber)?.intValue ?? channel["foregroundColor"] as? Int {
            foregroundColor = foregroundValue
        }

        if let style = channel["style"] as? [String: Any] {
            if let styleTint = (style["tint"] as? NSNumber)?.intValue ?? style["tint"] as? Int {
                tint = styleTint
            }

            if let styleForeground = (style["foregroundColor"] as? NSNumber)?.intValue ?? style["foregroundColor"] as? Int {
                foregroundColor = styleForeground
            }
        }
    }

    func toChannel() -> [String: Any] {
        var result: [String: Any] = [:]

        if let tag {
            result["tag"] = tag.base
        }

        if let padding {
            result["padding"] = padding
        }

        if let controlSize {
            result["controlSize"] = controlSize
        }

        if let enabled {
            result["enabled"] = enabled
        }

        if let width {
            result["width"] = width
        }

        if let height {
            result["height"] = height
        }

        var style: [String: Any] = [:]
        if let tint {
            style["tint"] = tint
        }
        if let foregroundColor {
            style["foregroundColor"] = foregroundColor
        }

        if !style.isEmpty {
            result["style"] = style
        }

        return result
    }
}
