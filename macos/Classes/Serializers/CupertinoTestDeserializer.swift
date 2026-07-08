import SwiftUI

enum DeserializerUtils {
    static func deepMerge(_ base: [String: Any], with patch: [String: Any]) -> [String: Any] {
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

struct CNBoxConstraintsPayload {
    let minWidth: CGFloat?
    let maxWidth: CGFloat?
    let minHeight: CGFloat?
    let maxHeight: CGFloat?

    var tightWidth: CGFloat? {
        minWidth == maxWidth ? minWidth : nil
    }

    var tightHeight: CGFloat? {
        minHeight == maxHeight ? minHeight : nil
    }

    static func fromChannel(_ channel: [String: Any]?) -> CNBoxConstraintsPayload? {
        guard let map = channel else {
            return nil
        }

        return CNBoxConstraintsPayload(
            minWidth: CNChannelDeserialization.decodeCGFloat(map["minWidth"]),
            maxWidth: CNChannelDeserialization.decodeCGFloat(map["maxWidth"]),
            minHeight: CNChannelDeserialization.decodeCGFloat(map["minHeight"]),
            maxHeight: CNChannelDeserialization.decodeCGFloat(map["maxHeight"]),
        )
    }

    func identityKey() -> String {
        [
            minWidth.map { String(describing: $0) } ?? "nil",
            maxWidth.map { String(describing: $0) } ?? "nil",
            minHeight.map { String(describing: $0) } ?? "nil",
            maxHeight.map { String(describing: $0) } ?? "nil",
        ].joined(separator: "|")
    }
}

struct CNTestPayload: CNChannelDeserializable {
    var systemSymbolName: String
    var viewDebugId: String
    var shrink: Bool
    var constraints: CNBoxConstraintsPayload?
    var font: [String: Any]?
    var tint: Int?
    var foregroundColor: Int?
    var symbolRenderingMode: String?
    var symbolColorRenderingMode: String?
    var foregroundStyleColors: [Int]

    init(viewId: String) {
        systemSymbolName = "questionmark.circle"
        viewDebugId = viewId
        font = nil
        shrink = false
        constraints = nil
        tint = nil
        foregroundColor = nil
        symbolRenderingMode = nil
        symbolColorRenderingMode = nil
        foregroundStyleColors = []
    }

    init?(channel: [String: Any], viewId: Int64) {
        guard channel["systemSymbolName"] != nil else {
            return nil
        }

        let viewDebugId: String = channel["debugWidgetId"] as? String ?? String(viewId)
        self.init(viewId: viewDebugId)
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        NSLog("[CNTestPayload_\(viewDebugId)][Swift] Applying patch: \(channel)")
        if channel.keys.contains("systemSymbolName"),
           let symbol = channel["systemSymbolName"] as? String,
           !symbol.isEmpty
        {
            systemSymbolName = symbol
        }

        if channel.keys.contains("font") {
            if channel["font"] is NSNull {
                font = nil
            } else if let fontPatch = channel["font"] as? [String: Any] {
                if let current = font {
                    font = DeserializerUtils.deepMerge(current, with: fontPatch)
                } else {
                    font = fontPatch
                }
            } else {
                font = nil
            }
        }

        if channel.keys.contains("shrink") {
            shrink = CNChannelDeserialization.decodeBool(channel["shrink"]) ?? false
        }

        if channel.keys.contains("constraints") {
            if channel["constraints"] is NSNull {
                constraints = nil
            } else if let constraintsMap = channel["constraints"] as? [String: Any] {
                constraints = CNBoxConstraintsPayload.fromChannel(constraintsMap)
            } else {
                constraints = nil
            }
        }

        if channel.keys.contains("tint") {
            tint = CNChannelDeserialization.decodeInt(channel["tint"])
        }

        if channel.keys.contains("foregroundColor") {
            foregroundColor = CNChannelDeserialization.decodeInt(channel["foregroundColor"])
        }

        if channel.keys.contains("symbolRenderingMode") {
            symbolRenderingMode = CNChannelDeserialization.decodeString(channel["symbolRenderingMode"])
        }

        if channel.keys.contains("symbolColorRenderingMode") {
            symbolColorRenderingMode = CNChannelDeserialization.decodeString(channel["symbolColorRenderingMode"])
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

    func identityKey() -> String {
        let fontKey = font.map { String(describing: $0) } ?? "nil"
        let tintKey = tint.map { String(describing: $0) } ?? "nil"
        let foregroundColorKey = foregroundColor.map { String(describing: $0) } ?? "nil"
        let constraintsKey = constraints?.identityKey() ?? "nil"
        let shrinkKey = String(describing: shrink)
        let symbolRenderingModeKey = symbolRenderingMode ?? "nil"
        let symbolColorRenderingModeKey = symbolColorRenderingMode ?? "nil"
        let foregroundStyleColorsKey = foregroundStyleColors.map { String(describing: $0) }.joined(separator: ",")
        return [
            viewDebugId,
            systemSymbolName,
            fontKey,
            tintKey,
            foregroundColorKey,
            constraintsKey,
            shrinkKey,
            symbolRenderingModeKey,
            symbolColorRenderingModeKey,
            foregroundStyleColorsKey,
        ].joined(separator: "|")
    }
}

final class CNTestViewModel: ObservableObject {
    @Published private(set) var payload: CNTestPayload

    init(payload: CNTestPayload) {
        self.payload = payload
    }

    func replace(with payload: CNTestPayload) {
        NSLog("[CNTestViewModel_\(payload.viewDebugId)][Swift] Replacing payload with new payload: \(payload)")
        self.payload = payload
    }

    func applyPatch(_ patch: [String: Any]) {
        NSLog("[CNTestViewModel_\(payload.viewDebugId)][Swift] Applying patch: \(patch)")
        var next = payload
        next.applyPatch(patch)
        payload = next
    }
}

enum CNTest {
    static func deserialize(model: CNTestViewModel, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        AnyView(_CNBoundTestView(model: model, onSizeChanged: onSizeChanged))
    }

    static func identityKey(for payload: CNTestPayload) -> String {
        payload.identityKey()
    }

    private struct _CNBoundTestView: View {
        @ObservedObject var model: CNTestViewModel
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload
            var view = AnyView(Image(systemName: payload.systemSymbolName))
            view = applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)
            view = applyFont(payload.font, to: view)
            view = applyForegroundColor(payload.foregroundColor, to: view)
            view = applyTint(payload.tint, to: view)
            view = applyColorRenderingMode(to: view, payload: payload)
            view = applyRenderingMode(to: view, payload: payload)

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
    }

    static func applyConstraints(constraints: CNBoxConstraintsPayload?, shrink: Bool, to view: AnyView) -> AnyView {
        guard let constraints, shrink == false else {
            return view
        }

        let minWidth = constraints.minWidth.map { CGFloat($0) }
        let idealWidth = constraints.tightWidth.map { CGFloat($0) }
        let maxWidth = constraints.maxWidth.map { CGFloat($0) }
        let minHeight = constraints.minHeight.map { CGFloat($0) }
        let idealHeight = constraints.tightHeight.map { CGFloat($0) }
        let maxHeight = constraints.maxHeight.map { CGFloat($0) }

        let framed = view.frame(
            minWidth: minWidth,
            idealWidth: idealWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            idealHeight: idealHeight,
            maxHeight: maxHeight,
        )

        return AnyView(framed)
    }

    static func applyFont(_ fontDict: [String: Any]?, to view: AnyView) -> AnyView {
        guard let fontDict else {
            return view
        }

        if let symbolFont = FontUtils.swiftUIFontFromDictionary(fontDict) {
            return AnyView(view.font(symbolFont))
        }

        return view
    }

    static func applyForegroundColor(_ foregroundColor: Int?, to view: AnyView) -> AnyView {
        guard let foregroundColor else {
            return view
        }

        return AnyView(view.foregroundColor(ColorUtils.swiftUIColorFromARGB(foregroundColor)))
    }

    static func applyTint(_ tint: Int?, to view: AnyView) -> AnyView {
        guard let tint else {
            return view
        }

        return AnyView(view.tint(ColorUtils.swiftUIColorFromARGB(tint)))
    }

    @available(macOS 15.0, *)
    static func applyColorRenderingMode(to view: AnyView, payload: CNTestPayload) -> AnyView {
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
    static func applyRenderingMode(to view: AnyView, payload: CNTestPayload) -> AnyView {
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
            if let first = payload.foregroundStyleColors.first {
                return AnyView(
                    view
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                )
            }
            return AnyView(view.symbolRenderingMode(.multicolor))
        default:
            return view
        }
    }
}
