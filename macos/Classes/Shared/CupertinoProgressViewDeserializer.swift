import Cocoa
import SwiftUI

struct CNProgressViewPayload: CNChannelSerializable {
    let controlSize: String?
    let height: Double?
    let isDark: Bool?
    let total: Double?
    let style: String?
    let tint: Int?
    let value: Double?
    let width: Double?

    init?(channel: [String: Any]) {
        controlSize = channel["controlSize"] as? String
        height = (channel["height"] as? NSNumber)?.doubleValue ?? channel["height"] as? Double
        isDark = (channel["isDark"] as? NSNumber)?.boolValue ?? channel["isDark"] as? Bool
        total = (channel["total"] as? NSNumber)?.doubleValue ?? channel["total"] as? Double
        style = channel["style"] as? String
        tint = (channel["tint"] as? NSNumber)?.intValue ?? channel["tint"] as? Int
        value = (channel["value"] as? NSNumber)?.doubleValue ?? channel["value"] as? Double
        width = (channel["width"] as? NSNumber)?.doubleValue ?? channel["width"] as? Double
    }

    func toChannel() -> [String: Any] {
        [
            "controlSize": controlSize as Any,
            "height": height as Any,
            "isDark": isDark as Any,
            "total": total as Any,
            "style": style as Any,
            "tint": tint as Any,
            "value": value as Any,
            "width": width as Any,
        ]
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

        if let tint = payload.tint {
            progressView = AnyView(progressView.tint(ColorUtils.swiftUIColorFromARGB(tint)))
        }

        if let width = payload.width, let height = payload.height {
            progressView = AnyView(progressView.frame(width: CGFloat(width), height: CGFloat(height)))
        } else if let width = payload.width {
            progressView = AnyView(progressView.frame(width: CGFloat(width)))
        } else if let height = payload.height {
            progressView = AnyView(progressView.frame(height: CGFloat(height)))
        }

        progressView = applyControlSize(to: progressView, controlSize: payload.controlSize)

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

    private static func applyControlSize(to view: AnyView, controlSize: String?) -> AnyView {
        switch controlSize {
        case "mini":
            return AnyView(view.controlSize(.mini))
        case "small":
            return AnyView(view.controlSize(.small))
        case "regular":
            return AnyView(view.controlSize(.regular))
        case "large":
            return AnyView(view.controlSize(.large))
        case "extraLarge":
            if #available(macOS 14.0, *) {
                return AnyView(view.controlSize(.extraLarge))
            }
            return AnyView(view.controlSize(.large))
        default:
            return view
        }
    }

    private static func identityKey(for payload: CNProgressViewPayload) -> String {
        let styleKey = payload.style ?? "nil"
        let controlSizeKey = payload.controlSize ?? "nil"
        let tintKey = payload.tint.map { String($0) } ?? "nil"
        let valueKey = payload.value.map { String($0) } ?? "nil"
        let totalKey = payload.total.map { String($0) } ?? "nil"
        let widthKey = payload.width.map { String($0) } ?? "nil"
        let heightKey = payload.height.map { String($0) } ?? "nil"
        let darkKey = payload.isDark.map { String($0) } ?? "nil"

        return [styleKey, controlSizeKey, tintKey, valueKey, totalKey, widthKey, heightKey, darkKey].joined(
            separator: "|",
        )
    }
}
