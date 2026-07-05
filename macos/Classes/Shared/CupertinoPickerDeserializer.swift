import Cocoa
import SwiftUI

struct CNPickerPayload: CNChannelSerializable {
    var items: [[String: Any]]
    var labelChildren: [[String: Any]]
    var selectedIndex: Int
    var isDark: Bool
    var pickerStyleName: String
    var asList: Bool
    var viewModifiers: CNViewModifiersPayload

    init() {
        items = []
        labelChildren = []
        selectedIndex = 0
        isDark = false
        pickerStyleName = "automatic"
        asList = false
        viewModifiers = CNViewModifiersPayload()
    }

    init?(channel: [String: Any]) {
        self.init()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        viewModifiers.applyPatch(channel)

        if let arr = channel["items"] as? [[String: Any]] {
            items = arr
        }

        if let arr = channel["labelChildren"] as? [[String: Any]] {
            labelChildren = arr
        }

        if let v = (channel["selectedIndex"] as? NSNumber)?.intValue ?? channel["selectedIndex"] as? Int {
            selectedIndex = v
        }

        if let v = (channel["isDark"] as? NSNumber)?.boolValue ?? channel["isDark"] as? Bool {
            isDark = v
        }

        if let styleName = channel["pickerStyle"] as? String {
            pickerStyleName = styleName
        }

        if let displayAsList = (channel["asList"] as? NSNumber)?.boolValue ?? channel["asList"] as? Bool {
            asList = displayAsList
        }
    }

    func toChannel() -> [String: Any] {
        var result = viewModifiers.toChannel()
        result.merge([
            "items": items,
            "labelChildren": labelChildren,
            "selectedIndex": selectedIndex,
            "isDark": isDark,
            "pickerStyle": pickerStyleName,
            "asList": asList,
        ]) { _, new in new }

        return result
    }
}

enum CNPickerDeserializer {
    static func decode(_ raw: Any?) -> CNPickerPayload? {
        CNChannelSerialization.decode(raw)
    }

    static func applyPatch(_ raw: Any?, to payload: inout CNPickerPayload) -> Bool {
        guard let dict = CNChannelSerialization.asDict(raw) else {
            return false
        }

        payload.applyPatch(dict)
        return true
    }

    static func itemTag(for item: [String: Any], fallback index: Int) -> Int {
        if let numberTag = (item["tag"] as? NSNumber)?.intValue {
            return numberTag
        }

        if let intTag = item["tag"] as? Int {
            return intTag
        }

        // Picker selection binding is Int-based, so non-int tags fall back to index.
        return index
    }
}
