import SwiftUI

struct CNTextPayload: CNChannelSerializable {
    let color: Int?
    let font: [String: Any]?
    let lineLimit: Int?
    let lineLimitReservesSpace: Bool?
    let height: Double?
    let padding: [String: Any]?
    let tag: AnyHashable?
    let string: String
    let textScale: String?
    let truncationMode: String?
    let width: Double?
    let viewModifiers: CNViewModifiersPayload

    init?(channel: [String: Any]) {
        guard let string = channel["text"] as? String else {
            return nil
        }

        let modifiers = CNViewModifiersPayload(channel: channel)
        self.string = string
        color = (channel["color"] as? NSNumber)?.intValue ?? channel["color"] as? Int
        font = channel["font"] as? [String: Any]
        padding = modifiers.padding
        tag = modifiers.tag
        lineLimit = (channel["lineLimit"] as? NSNumber)?.intValue ?? channel["lineLimit"] as? Int
        lineLimitReservesSpace = (channel["lineLimitReservesSpace"] as? NSNumber)?.boolValue ?? channel["lineLimitReservesSpace"] as? Bool
        height = modifiers.height
        textScale = channel["textScale"] as? String
        truncationMode = channel["truncationMode"] as? String
        width = modifiers.width
        viewModifiers = modifiers
    }

    func toChannel() -> [String: Any] {
        var result = viewModifiers.toChannel()
        result["text"] = string
        result["color"] = color
        result["font"] = font
        result["lineLimit"] = lineLimit
        result["lineLimitReservesSpace"] = lineLimitReservesSpace
        result["textScale"] = textScale
        result["truncationMode"] = truncationMode
        return result
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

    private static func view(from payload: CNTextPayload, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        var view = AnyView(Text(payload.string))

        if let fontDict = payload.font,
           let symbolFont = FontUtils.swiftUIFontFromDictionary(fontDict)
        {
            view = AnyView(view.font(symbolFont))
        }

        if let color = payload.color {
            view = AnyView(view.foregroundColor(ColorUtils.swiftUIColorFromARGB(color)))
        }

        if let lineLimit = payload.lineLimit {
            view = AnyView(view.lineLimit(lineLimit, reservesSpace: payload.lineLimitReservesSpace ?? false))
        }

        view = CNViewPadding.apply(payload.padding, to: view)

        if #available(macOS 14.0, *) {
            view = applyTextScale(to: view, payload: payload)
        }

        view = applyTruncationMode(to: view, payload: payload)

        view = CNViewTag.apply(payload.tag, to: view)

        if let width = payload.width, let height = payload.height {
            view = AnyView(view.frame(width: CGFloat(width), height: CGFloat(height)))
        } else if let width = payload.width {
            view = AnyView(view.frame(width: CGFloat(width)))
        } else if let height = payload.height {
            view = AnyView(view.frame(height: CGFloat(height)))
        }

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

        let colorKey = if let color = payload.color {
            "\(color)"
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
        let paddingKey = if let padding = payload.padding {
            String(describing: padding)
        } else {
            "nil"
        }
        let tagKey = if let tag = payload.tag {
            "\(tag)"
        } else {
            "nil"
        }

        let widthKey = if let width = payload.width {
            "\(width)"
        } else {
            "nil"
        }

        let heightKey = if let height = payload.height {
            "\(height)"
        } else {
            "nil"
        }

        var components: [String] = []
        components.append(payload.string)
        components.append(colorKey)
        components.append(fontKey)
        components.append(lineLimitKey)
        components.append(reservesSpaceKey)
        components.append(textScaleKey)
        components.append(truncationModeKey)
        components.append(paddingKey)
        components.append(tagKey)
        components.append(widthKey)
        components.append(heightKey)

        return components.joined(separator: "|")
    }
}
