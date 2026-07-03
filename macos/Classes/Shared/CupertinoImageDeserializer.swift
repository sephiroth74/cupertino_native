import SwiftUI

protocol CNChannelSerializable {
    init?(channel: [String: Any])
    func toChannel() -> [String: Any]
}

enum CNChannelSerialization {
    static func asDict(_ value: Any?) -> [String: Any]? {
        value as? [String: Any]
    }

    static func asArray(_ value: Any?) -> [Any] {
        value as? [Any] ?? []
    }

    static func decode<T: CNChannelSerializable>(_ value: Any?) -> T? {
        guard let dict = asDict(value) else { return nil }
        return T(channel: dict)
    }

    static func decodeArray<T: CNChannelSerializable>(_ value: Any?) -> [T] {
        asArray(value).compactMap { decode($0) as T? }
    }

    static func encode<T: CNChannelSerializable>(_ value: T?) -> [String: Any]? {
        value?.toChannel()
    }

    static func encodeArray<T: CNChannelSerializable>(_ values: [T]) -> [[String: Any]] {
        values.map { $0.toChannel() }
    }
}

struct CNImagePayload: CNChannelSerializable {
    let systemSymbolName: String
    let symbolRenderingMode: String?
    let symbolColorRenderingMode: String?
    let foregroundStyleColors: [Int]
    let tint: Int?
    let font: [String: Any]?

    init?(channel: [String: Any]) {
        guard let systemSymbolName = channel["systemSymbolName"] as? String, !systemSymbolName.isEmpty else {
            return nil
        }

        self.systemSymbolName = systemSymbolName
        symbolRenderingMode = channel["symbolRenderingMode"] as? String
        symbolColorRenderingMode = channel["symbolColorRenderingMode"] as? String
        tint = (channel["tint"] as? NSNumber)?.intValue ?? channel["tint"] as? Int
        font = channel["font"] as? [String: Any]

        if let rawColors = channel["foregroundStyleColors"] as? [NSNumber] {
            foregroundStyleColors = rawColors.map { $0.intValue }
        } else if let rawColors = channel["foregroundStyleColors"] as? [Int] {
            foregroundStyleColors = rawColors
        } else {
            foregroundStyleColors = []
        }
    }

    func toChannel() -> [String: Any] {
        var result: [String: Any] = ["systemSymbolName": systemSymbolName]
        result["symbolRenderingMode"] = symbolRenderingMode
        result["symbolColorRenderingMode"] = symbolColorRenderingMode
        result["foregroundStyleColors"] = foregroundStyleColors
        result["tint"] = tint
        result["font"] = font
        return result
    }
}

enum CNImage {
    static func deserialize(_ raw: Any?) -> AnyView? {
        if let payload: CNImagePayload = CNChannelSerialization.decode(raw) {
            return view(from: payload)
        }

        if let jsonString = raw as? String {
            return deserialize(jsonString: jsonString)
        }

        return nil
    }

    static func deserialize(jsonString: String) -> AnyView? {
        do {
            if let imageDict = try JSONSerialization.jsonObject(
                with: Data(jsonString.utf8), options: []
            ) as? [String: Any] {
                return deserialize(imageDict)
            }
        } catch {
            NSLog("Error deserializing image JSON string: \(error)")
        }
        return nil
    }

    static func deserialize(_ dict: [String: Any]) -> AnyView? {
        guard let payload = CNImagePayload(channel: dict) else {
            return nil
        }

        return view(from: payload)
    }

    private static func view(from payload: CNImagePayload) -> AnyView {
        var view = AnyView(Image(systemName: payload.systemSymbolName))

        if let fontDict = payload.font,
           let symbolFont = FontUtils.swiftUIFontFromDictionary(fontDict)
        {
            view = AnyView(view.font(symbolFont))
        }

        if #available(macOS 12.0, *) {
            view = applyRenderingMode(to: view, payload: payload)
        }

        if #available(macOS 15.0, *) {
            view = applyColorRenderingMode(to: view, payload: payload)
        }

        if let tintColorValue = payload.tint {
            view = AnyView(view.foregroundColor(colorFromARGB(tintColorValue)))
        }

        return AnyView(view.id(identityKey(for: payload)))
    }

    private static func identityKey(for payload: CNImagePayload) -> String {
        let colors = payload.foregroundStyleColors.map(String.init).joined(separator: ",")
        let fontKey = payload.font.map { String(describing: $0) } ?? "nil"
        let tintKey = payload.tint.map(String.init) ?? "nil"
        return [
            payload.systemSymbolName,
            payload.symbolRenderingMode ?? "nil",
            payload.symbolColorRenderingMode ?? "nil",
            colors,
            tintKey,
            fontKey,
        ].joined(separator: "|")
    }

    @available(macOS 15.0, *)
    private static func applyColorRenderingMode(to view: AnyView, payload: CNImagePayload) -> AnyView {
        switch payload.symbolColorRenderingMode {
        case "flat":
            return AnyView(view.symbolColorRenderingMode(.flat))
        case "gradient":
            return AnyView(view.symbolColorRenderingMode(.gradient))
        default:
            return view
        }
    }

    @available(macOS 12.0, *)
    private static func applyRenderingMode(to view: AnyView, payload: CNImagePayload) -> AnyView {
        switch payload.symbolRenderingMode {
        case "hierarchical":
            if let first = payload.foregroundStyleColors.first {
                return AnyView(
                    view
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(colorFromARGB(first))
                )
            }
            return AnyView(view.symbolRenderingMode(.hierarchical))
        case "monochrome":
            if let first = payload.foregroundStyleColors.first {
                return AnyView(
                    view
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(colorFromARGB(first))
                )
            }
            return AnyView(view.symbolRenderingMode(.monochrome))
        case "palette":
            let palette = payload.foregroundStyleColors.map(colorFromARGB)
            guard !palette.isEmpty else {
                return AnyView(view.symbolRenderingMode(.palette))
            }
            if palette.count == 1 {
                return AnyView(
                    view
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(palette[0])
                )
            }
            if palette.count == 2 {
                return AnyView(
                    view
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(palette[0], palette[1])
                )
            }
            return AnyView(
                view
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(palette[0], palette[1], palette[2])
            )
        case "multicolor":
            return AnyView(view.symbolRenderingMode(.multicolor))
        default:
            return view
        }
    }

    private static func colorFromARGB(_ argb: Int) -> Color {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

enum CupertinoImageDeserializer {
    static func deserialize(dict: [String: Any]) -> AnyView? {
        CNImage.deserialize(dict)
    }

    static func deserialize(jsonString: String) -> AnyView? {
        CNImage.deserialize(jsonString: jsonString)
    }
}
