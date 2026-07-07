import SwiftUI

struct CNImagePayload: CNChannelSerializable {
    var systemSymbolName: String
    var symbolRenderingMode: String?
    var symbolColorRenderingMode: String?
    var foregroundStyleColors: [Int]
    var font: [String: Any]?
    var viewModifiers: CNViewModifiersPayload

    init() {
        systemSymbolName = "questionmark.circle"
        symbolRenderingMode = nil
        symbolColorRenderingMode = nil
        foregroundStyleColors = []
        font = nil
        viewModifiers = CNViewModifiersPayload()
    }

    init?(channel: [String: Any]) {
        guard channel["systemSymbolName"] != nil else {
            return nil
        }

        self.init()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        viewModifiers.applyPatch(channel)

        if channel.keys.contains("systemSymbolName"),
           let symbol = channel["systemSymbolName"] as? String,
           !symbol.isEmpty
        {
            systemSymbolName = symbol
        }

        if channel.keys.contains("symbolRenderingMode") {
            symbolRenderingMode = Self.decodeString(channel["symbolRenderingMode"])
        }

        if channel.keys.contains("symbolColorRenderingMode") {
            symbolColorRenderingMode = Self.decodeString(channel["symbolColorRenderingMode"])
        }

        if channel.keys.contains("font") {
            if channel["font"] is NSNull {
                font = nil
            } else if let fontPatch = channel["font"] as? [String: Any] {
                if let current = font {
                    font = Self.deepMerge(current, with: fontPatch)
                } else {
                    font = fontPatch
                }
            } else {
                font = nil
            }
        }

        if channel.keys.contains("foregroundStyleColors") {
            if channel["foregroundStyleColors"] is NSNull {
                foregroundStyleColors = []
            } else if let rawColors = channel["foregroundStyleColors"] as? [NSNumber] {
                foregroundStyleColors = rawColors.map(\.intValue)
            } else if let rawColors = channel["foregroundStyleColors"] as? [Int] {
                foregroundStyleColors = rawColors
            } else {
                foregroundStyleColors = []
            }
        }
    }

    private static func decodeString(_ value: Any?) -> String? {
        if value is NSNull {
            return nil
        }
        return value as? String
    }

    private static func deepMerge(_ base: [String: Any], with patch: [String: Any]) -> [String: Any] {
        var result = base

        for (key, patchValue) in patch {
            if patchValue is NSNull {
                result.removeValue(forKey: key)
                continue
            }

            if let patchMap = patchValue as? [String: Any],
               let baseMap = result[key] as? [String: Any]
            {
                result[key] = deepMerge(baseMap, with: patchMap)
            } else {
                result[key] = patchValue
            }
        }

        return result
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

final class CNImageViewModel: ObservableObject {
    @Published private(set) var payload: CNImagePayload

    init(payload: CNImagePayload) {
        self.payload = payload
    }

    func replace(with payload: CNImagePayload) {
        self.payload = payload
    }

    func applyPatch(_ patch: [String: Any]) {
        var next = payload
        next.applyPatch(patch)
        payload = next
    }
}

enum CNImage {
    static func deserialize(_ raw: Any?, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView? {
        if let payload: CNImagePayload = CNChannelSerialization.decode(raw) {
            return view(from: payload, onSizeChanged: onSizeChanged)
        }

        if let jsonString = raw as? String {
            return deserialize(jsonString: jsonString, onSizeChanged: onSizeChanged)
        }

        return nil
    }

    static func deserialize(jsonString: String, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView? {
        do {
            if let imageDict = try JSONSerialization.jsonObject(
                with: Data(jsonString.utf8), options: [],
            ) as? [String: Any] {
                return deserialize(imageDict, onSizeChanged: onSizeChanged)
            }
        } catch {
            NSLog("Error deserializing image JSON string: \(error)")
        }
        return nil
    }

    static func deserialize(_ dict: [String: Any], onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView? {
        guard let payload = CNImagePayload(channel: dict) else {
            return nil
        }

        return view(from: payload, onSizeChanged: onSizeChanged)
    }

    static func deserialize(model: CNImageViewModel, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        AnyView(_CNBoundImageView(model: model, onSizeChanged: onSizeChanged))
    }

    private static func view(from payload: CNImagePayload, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
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

        if let onSizeChanged {
            view = AnyView(
                view.onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newSize in
                    onSizeChanged(newSize)
                },
            )
        }

        return AnyView(view.id(identityKey(for: payload)))
    }

    private struct _CNBoundImageView: View {
        @ObservedObject var model: CNImageViewModel
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload
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

            if let onSizeChanged {
                view = AnyView(
                    view.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newSize in
                        onSizeChanged(newSize)
                    },
                )
            }

            return view
        }
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
