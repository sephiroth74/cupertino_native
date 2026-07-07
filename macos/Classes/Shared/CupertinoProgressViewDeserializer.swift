import Cocoa
import SwiftUI

struct CNProgressViewPayload: CNChannelSerializable {
    var isDark: Bool?
    var total: Double?
    var style: String?
    var value: Double?
    var viewModifiers: CNViewModifiersPayload

    init() {
        isDark = nil
        total = 1.0
        style = "linear"
        value = nil
        viewModifiers = CNViewModifiersPayload()
    }

    init?(channel: [String: Any]) {
        self.init()
        applyPatch(channel)
    }

    mutating func applyPatch(_ channel: [String: Any]) {
        viewModifiers.applyPatch(channel)

        if channel.keys.contains("isDark") {
            isDark = Self.decodeBool(channel["isDark"])
        }

        if channel.keys.contains("total") {
            total = Self.decodeDouble(channel["total"])
        }

        if channel.keys.contains("style") {
            style = Self.decodeString(channel["style"])
        }

        if channel.keys.contains("value") {
            value = Self.decodeDouble(channel["value"])
        }
    }

    private static func decodeBool(_ value: Any?) -> Bool? {
        if value is NSNull {
            return nil
        }
        return (value as? NSNumber)?.boolValue ?? value as? Bool
    }

    private static func decodeDouble(_ value: Any?) -> Double? {
        if value is NSNull {
            return nil
        }
        return (value as? NSNumber)?.doubleValue ?? value as? Double
    }

    private static func decodeString(_ value: Any?) -> String? {
        if value is NSNull {
            return nil
        }
        return value as? String
    }

    func toChannel() -> [String: Any] {
        var result = viewModifiers.toChannel()
        result["isDark"] = isDark
        result["total"] = total
        result["style"] = style
        result["value"] = value
        return result
    }
}

final class CNProgressViewModel: ObservableObject {
    @Published private(set) var payload: CNProgressViewPayload

    init(payload: CNProgressViewPayload) {
        self.payload = payload
    }

    func replace(with payload: CNProgressViewPayload) {
        self.payload = payload
    }

    func applyPatch(_ patch: [String: Any]) {
        var next = payload
        next.applyPatch(patch)
        payload = next
    }
}

enum CNProgressViewDeserializer {
    static func decode(_ raw: Any?) -> CNProgressViewPayload? {
        CNChannelSerialization.decode(raw)
    }

    static func deserialize(
        _ raw: Any?,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload: CNProgressViewPayload = CNChannelSerialization.decode(raw) else {
            return nil
        }

        return view(from: payload, onSizeChanged: onSizeChanged)
    }

    static func deserialize(
        _ dict: [String: Any],
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView? {
        guard let payload = CNProgressViewPayload(channel: dict) else {
            return nil
        }

        return view(from: payload, onSizeChanged: onSizeChanged)
    }

    static func deserialize(
        model: CNProgressViewModel,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundProgressView(model: model, onSizeChanged: onSizeChanged))
    }

    private static func view(
        from payload: CNProgressViewPayload,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        let total = max(payload.total ?? 1.0, 0.000001)

        var progressView: AnyView = {
            if let rawValue = payload.value {
                let clampedValue = Swift.min(Swift.max(rawValue, 0.0), total)
                return AnyView(ProgressView(value: clampedValue, total: total))
            }

            return AnyView(ProgressView())
        }()

        progressView = applyStyle(to: progressView, style: payload.style)
        progressView = CNViewModifiers.apply(payload.viewModifiers, to: progressView)

        if let onSizeChanged {
            progressView = AnyView(
                progressView.onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newSize in
                    onSizeChanged(newSize)
                },
            )
        }

        return AnyView(progressView.id(identityKey(for: payload)))
    }

    private struct _CNBoundProgressView: View {
        @ObservedObject var model: CNProgressViewModel
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload
            let total = max(payload.total ?? 1.0, 0.000001)

            var progressView: AnyView = {
                if let rawValue = payload.value {
                    let clampedValue = Swift.min(Swift.max(rawValue, 0.0), total)
                    return AnyView(ProgressView(value: clampedValue, total: total))
                }

                return AnyView(ProgressView())
            }()

            progressView = applyStyle(to: progressView, style: payload.style)
            progressView = CNViewModifiers.apply(payload.viewModifiers, to: progressView)

            if let onSizeChanged {
                progressView = AnyView(
                    progressView.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newSize in
                        onSizeChanged(newSize)
                    },
                )
            }

            return AnyView(progressView.id(identityKey(for: payload)))
        }
    }

    private static func applyStyle(to view: AnyView, style: String?) -> AnyView {
        switch style {
        case "linear":
            AnyView(view.progressViewStyle(.linear))
        case "circular":
            AnyView(view.progressViewStyle(.circular))
        default:
            view
        }
    }

    private static func identityKey(for payload: CNProgressViewPayload) -> String {
        let styleKey = payload.style ?? "nil"
        let modifiersKey = payload.viewModifiers.identityKey()
        let valueKey = payload.value.map { String($0) } ?? "nil"
        let totalKey = payload.total.map { String($0) } ?? "nil"
        let darkKey = payload.isDark.map { String($0) } ?? "nil"

        return [styleKey, modifiersKey, valueKey, totalKey, darkKey].joined(
            separator: "|",
        )
    }
}
