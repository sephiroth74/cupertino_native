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

    static func encode(_ value: (some CNChannelSerializable)?) -> [String: Any]? {
        value?.toChannel()
    }

    static func encodeArray(_ values: [some CNChannelSerializable]) -> [[String: Any]] {
        values.map { $0.toChannel() }
    }
}

struct CNImagePayload: CNChannelSerializable {
    let systemSymbolName: String
    let symbolRenderingMode: String?
    let symbolColorRenderingMode: String?
    let foregroundStyleColors: [Int]
    let font: [String: Any]?
    let viewModifiers: CNViewModifiersPayload

    init?(channel: [String: Any]) {
        guard let systemSymbolName = channel["systemSymbolName"] as? String, !systemSymbolName.isEmpty else {
            return nil
        }

        let modifiers = CNViewModifiersPayload(channel: channel)
        self.systemSymbolName = systemSymbolName
        symbolRenderingMode = channel["symbolRenderingMode"] as? String
        symbolColorRenderingMode = channel["symbolColorRenderingMode"] as? String
        font = channel["font"] as? [String: Any]
        viewModifiers = modifiers

        if let rawColors = channel["foregroundStyleColors"] as? [NSNumber] {
            foregroundStyleColors = rawColors.map(\.intValue)
        } else if let rawColors = channel["foregroundStyleColors"] as? [Int] {
            foregroundStyleColors = rawColors
        } else {
            foregroundStyleColors = []
        }
    }

    func toChannel() -> [String: Any] {
        var result = viewModifiers.toChannel()
        result["systemSymbolName"] = systemSymbolName
        result["symbolRenderingMode"] = symbolRenderingMode
        result["symbolColorRenderingMode"] = symbolColorRenderingMode
        result["foregroundStyleColors"] = foregroundStyleColors
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
                with: Data(jsonString.utf8), options: [],
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

        view = CNViewModifiers.apply(payload.viewModifiers, to: view)
        return AnyView(view.id(identityKey(for: payload)))
    }

    private static func identityKey(for payload: CNImagePayload) -> String {
        let colors = payload.foregroundStyleColors.map(String.init).joined(separator: ",")
        let fontKey = payload.font.map { String(describing: $0) } ?? "nil"
        let tintKey = payload.viewModifiers.tint.map(String.init) ?? "nil"
        let paddingKey = payload.viewModifiers.padding.map { String(describing: $0) } ?? "nil"
        let foregroundColorKey = payload.viewModifiers.foregroundColor.map { String(describing: $0) } ?? "nil"
        let tagKey = payload.viewModifiers.tag.map { "\($0)" } ?? "nil"
        return [
            payload.systemSymbolName,
            payload.symbolRenderingMode ?? "nil",
            payload.symbolColorRenderingMode ?? "nil",
            colors,
            tintKey,
            foregroundColorKey,
            fontKey,
            paddingKey,
            tagKey,
        ].joined(separator: "|")
    }

    @available(macOS 15.0, *)
    private static func applyColorRenderingMode(to view: AnyView, payload: CNImagePayload) -> AnyView {
        switch payload.symbolColorRenderingMode {
        case "flat":
            AnyView(view.symbolColorRenderingMode(.flat))
        case "gradient":
            AnyView(view.symbolColorRenderingMode(.gradient))
        default:
            view
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
                        .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                )
            }
            return AnyView(view.symbolRenderingMode(.hierarchical))
        case "monochrome":
            if let first = payload.foregroundStyleColors.first {
                return AnyView(
                    view
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                )
            }
            return AnyView(view.symbolRenderingMode(.monochrome))
        case "palette":
            let palette = payload.foregroundStyleColors.map(ColorUtils.swiftUIColorFromARGB)
            guard !palette.isEmpty else {
                return AnyView(view.symbolRenderingMode(.palette))
            }
            if palette.count == 1 {
                return AnyView(
                    view
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(palette[0]),
                )
            }
            if palette.count == 2 {
                return AnyView(
                    view
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(palette[0], palette[1]),
                )
            }
            return AnyView(
                view
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(palette[0], palette[1], palette[2]),
            )
        case "multicolor":
            return AnyView(view.symbolRenderingMode(.multicolor))
        default:
            return view
        }
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
