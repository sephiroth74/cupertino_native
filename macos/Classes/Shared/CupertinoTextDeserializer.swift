import SwiftUI

struct CNTextPayload: CNChannelSerializable {
    var font: [String: Any]?
    var lineLimit: Int?
    var lineLimitReservesSpace: Bool?
    var string: String
    var textScale: String?
    var truncationMode: String?
    var viewModifiers: CNViewModifiersPayload

    init() {
        font = nil
        lineLimit = nil
        lineLimitReservesSpace = nil
        string = ""
        textScale = nil
        truncationMode = nil
        viewModifiers = CNViewModifiersPayload()
    }

    init?(channel: [String: Any]) {
        guard channel["text"] != nil else {
            return nil
        }

        self.init()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        viewModifiers.applyPatch(channel)

        if channel.keys.contains("text") {
            string = Self.decodeString(channel["text"]) ?? ""
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

        if channel.keys.contains("lineLimit") {
            lineLimit = Self.decodeInt(channel["lineLimit"])
        }

        if channel.keys.contains("lineLimitReservesSpace") {
            lineLimitReservesSpace = Self.decodeBool(channel["lineLimitReservesSpace"])
        }

        if channel.keys.contains("textScale") {
            textScale = Self.decodeString(channel["textScale"])
        }

        if channel.keys.contains("truncationMode") {
            truncationMode = Self.decodeString(channel["truncationMode"])
        }
    }

    func toChannel() -> [String: Any] {
        var result = viewModifiers.toChannel()
        result["text"] = string
        result["font"] = font
        result["lineLimit"] = lineLimit
        result["lineLimitReservesSpace"] = lineLimitReservesSpace
        result["textScale"] = textScale
        result["truncationMode"] = truncationMode
        return result
    }

    private static func decodeBool(_ value: Any?) -> Bool? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.boolValue ?? value as? Bool
    }

    private static func decodeInt(_ value: Any?) -> Int? {
        if value is NSNull { return nil }
        return (value as? NSNumber)?.intValue ?? value as? Int
    }

    private static func decodeString(_ value: Any?) -> String? {
        if value is NSNull { return nil }
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
}

final class CNTextViewModel: ObservableObject {
    @Published private(set) var payload: CNTextPayload

    init(payload: CNTextPayload) {
        self.payload = payload
    }

    func replace(with payload: CNTextPayload) {
        self.payload = payload
    }

    func applyPatch(_ patch: [String: Any]) {
        var next = payload
        next.applyPatch(patch)
        payload = next
    }
}

enum CNText {
    static func deserialize(_ raw: Any?, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView? {
        if let payload: CNTextPayload = CNChannelSerialization.decode(raw) {
            return view(from: payload, onSizeChanged: onSizeChanged)
        }

        if let jsonString = raw as? String {
            return deserialize(jsonString: jsonString, onSizeChanged: onSizeChanged)
        }

        return nil
    }

    static func deserialize(jsonString: String, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView? {
        do {
            if let textDict = try JSONSerialization.jsonObject(with: Data(jsonString.utf8), options: []) as? [String: Any] {
                return deserialize(textDict, onSizeChanged: onSizeChanged)
            }
        } catch {
            NSLog("Error deserializing text JSON string: \(error)")
        }
        return nil
    }

    static func deserialize(_ dict: [String: Any], onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView? {
        guard let payload = CNTextPayload(channel: dict) else {
            return nil
        }

        return view(from: payload, onSizeChanged: onSizeChanged)
    }

    static func deserialize(model: CNTextViewModel, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        AnyView(_CNBoundTextView(model: model, onSizeChanged: onSizeChanged))
    }

    private static func view(from payload: CNTextPayload, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        var view = AnyView(Text(payload.string))

        if let fontDict = payload.font,
           let symbolFont = FontUtils.swiftUIFontFromDictionary(fontDict)
        {
            view = AnyView(view.font(symbolFont))
        } else if let fontDict = payload.font {
            NSLog("[CNText][Swift] Font map not resolvable in static view: \(fontDict)")
        }

        if let lineLimit = payload.lineLimit {
            view = AnyView(view.lineLimit(lineLimit, reservesSpace: payload.lineLimitReservesSpace ?? false))
        }

        if #available(macOS 14.0, *) {
            view = applyTextScale(to: view, payload: payload)
        }

        view = applyTruncationMode(to: view, payload: payload)
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

        let identifier = identityKey(for: payload)
        let identifiedView = view.id(identifier)
        return AnyView(identifiedView)
    }

    private struct _CNBoundTextView: View {
        @ObservedObject var model: CNTextViewModel
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            var view = AnyView(Text(payload.string))

            if let fontDict = payload.font,
               let symbolFont = FontUtils.swiftUIFontFromDictionary(fontDict)
            {
                view = AnyView(view.font(symbolFont))
            } else if let fontDict = payload.font {
                NSLog("[CNText][Swift] Font map not resolvable in bound view: \(fontDict)")
            }

            if let lineLimit = payload.lineLimit {
                view = AnyView(view.lineLimit(lineLimit, reservesSpace: payload.lineLimitReservesSpace ?? false))
            }

            if #available(macOS 14.0, *) {
                view = applyTextScale(to: view, payload: payload)
            }

            view = applyTruncationMode(to: view, payload: payload)
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

    @available(macOS 14.0, *)
    private static func applyTextScale(to view: AnyView, payload: CNTextPayload) -> AnyView {
        switch payload.textScale {
        case "defaultScale":
            AnyView(view.textScale(.default))
        case "secondary":
            AnyView(view.textScale(.secondary))
        default:
            view
        }
    }

    private static func applyTruncationMode(to view: AnyView, payload: CNTextPayload) -> AnyView {
        switch payload.truncationMode {
        case "head":
            AnyView(view.truncationMode(.head))
        case "middle":
            AnyView(view.truncationMode(.middle))
        case "tail":
            AnyView(view.truncationMode(.tail))
        default:
            view
        }
    }

    private static func identityKey(for payload: CNTextPayload) -> String {
        let fontKey = if let font = payload.font {
            String(describing: font)
        } else {
            "nil"
        }

        let lineLimitKey = if let lineLimit = payload.lineLimit {
            "\(lineLimit)"
        } else {
            "nil"
        }

        let reservesSpaceKey = if let reservesSpace = payload.lineLimitReservesSpace {
            "\(reservesSpace)"
        } else {
            "nil"
        }

        let textScaleKey = payload.textScale ?? "nil"
        let truncationModeKey = payload.truncationMode ?? "nil"
        let modifiersKey = payload.viewModifiers.identityKey()

        var components: [String] = []
        components.append(payload.string)
        components.append(fontKey)
        components.append(lineLimitKey)
        components.append(reservesSpaceKey)
        components.append(textScaleKey)
        components.append(truncationModeKey)
        components.append(modifiersKey)

        return components.joined(separator: "|")
    }
}
