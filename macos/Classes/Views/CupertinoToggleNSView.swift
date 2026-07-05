import Cocoa
import FlutterMacOS
import SwiftUI

struct CNToggleChildPayload: CNChannelSerializable {
    let payload: [String: Any]
    let type: String

    init?(channel: [String: Any]) {
        guard let type = channel["type"] as? String,
              let payload = channel["payload"] as? [String: Any]
        else {
            return nil
        }

        self.type = type
        self.payload = payload
    }

    func toChannel() -> [String: Any] {
        [
            "type": type,
            "payload": payload,
        ]
    }
}

struct CNTogglePayload: CNChannelSerializable {
    var controlSize: String?
    var enabled: Bool?
    var foregroundColor: Int?
    var height: Double?
    var isDark: Bool?
    var labelChildren: [CNToggleChildPayload]
    var tint: Int?
    var toggleStyle: String?
    var value: Bool?
    var width: Double?

    init?(channel: [String: Any]) {
        value = (channel["value"] as? NSNumber)?.boolValue ?? channel["value"] as? Bool
        enabled = (channel["enabled"] as? NSNumber)?.boolValue ?? channel["enabled"] as? Bool
        labelChildren = CNChannelSerialization.decodeArray(channel["labelChildren"])
        toggleStyle = channel["toggleStyle"] as? String
        isDark = (channel["isDark"] as? NSNumber)?.boolValue ?? channel["isDark"] as? Bool
        controlSize = channel["controlSize"] as? String
        tint = (channel["tint"] as? NSNumber)?.intValue ?? channel["tint"] as? Int
        foregroundColor = (channel["foregroundColor"] as? NSNumber)?.intValue ?? channel["foregroundColor"] as? Int
        width = (channel["width"] as? NSNumber)?.doubleValue ?? channel["width"] as? Double
        height = (channel["height"] as? NSNumber)?.doubleValue ?? channel["height"] as? Double
    }

    func toChannel() -> [String: Any] {
        [
            "value": value as Any,
            "enabled": enabled as Any,
            "labelChildren": CNChannelSerialization.encodeArray(labelChildren),
            "toggleStyle": toggleStyle as Any,
            "isDark": isDark as Any,
            "controlSize": controlSize as Any,
            "tint": tint as Any,
            "foregroundColor": foregroundColor as Any,
            "width": width as Any,
            "height": height as Any,
        ]
    }
}

final class CNToggleModel: ObservableObject {
    @Published var payload: CNTogglePayload
    let onChanged: (Bool) -> Void
    let onSizeChanged: (CGSize) -> Void

    init(payload: CNTogglePayload, onChanged: @escaping (Bool) -> Void, onSizeChanged: @escaping (CGSize) -> Void) {
        self.payload = payload
        self.onChanged = onChanged
        self.onSizeChanged = onSizeChanged
    }

    func setPayload(_ newPayload: CNTogglePayload) {
        payload = newPayload
    }

    func setValueFromDart(_ value: Bool) {
        var next = payload
        next.value = value
        payload = next
    }

    func setEnabledFromDart(_ enabled: Bool) {
        var next = payload
        next.enabled = enabled
        payload = next
    }

    func setValueFromUser(_ value: Bool) {
        var next = payload
        next.value = value
        payload = next
        onChanged(value)
    }
}

class CupertinoToggleNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>
    private let model: CNToggleModel
    private var payload: CNTogglePayload
    private var lastReportedIntrinsicSize: CGSize?

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))
        channel = FlutterMethodChannel(
            name: "CupertinoNativeToggle_\(viewId)", binaryMessenger: messenger,
        )

        payload = CNChannelSerialization.decode(args) ?? Self.defaultPayload()

        let channelRef = channel
        model = CNToggleModel(
            payload: payload,
            onChanged: { newValue in
                channelRef.invokeMethod("onChanged", arguments: ["value": newValue])
            },
            onSizeChanged: { newSize in
                channelRef.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": newSize.width, "height": newSize.height],
                )
            },
        )
        super.init(frame: .zero)

        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor

        addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        rebuild()

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "getIntrinsicSize":
                let size = self.currentIntrinsicSize()
                result(["width": size.width, "height": size.height])
            case "setToggle":
                if let parsed: CNTogglePayload = CNChannelSerialization.decode(call.arguments) {
                    self.payload = parsed
                    self.model.setPayload(parsed)
                    self.rebuild()
                    self.notifyIntrinsicSizeChanged(force: true)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Invalid toggle payload", details: nil))
                }
            case "setValue":
                if let args = CNChannelSerialization.asDict(call.arguments),
                   let value = (args["value"] as? NSNumber)?.boolValue
                {
                    self.model.setValueFromDart(value)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setIsEnabled":
                if let args = CNChannelSerialization.asDict(call.arguments),
                   let enabled = (args["value"] as? NSNumber)?.boolValue
                {
                    self.model.setEnabledFromDart(enabled)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder _: NSCoder) {
        nil
    }

    private static func defaultPayload() -> CNTogglePayload {
        CNTogglePayload(channel: [
            "value": false,
            "enabled": true,
            "labelChildren": [],
            "toggleStyle": "switch",
            "controlSize": "regular",
        ])!
    }

    private func rebuild() {
        if let isDark = payload.isDark {
            hostingView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        } else {
            hostingView.appearance = nil
        }

        hostingView.rootView = AnyView(CupertinoToggleView(model: model))

        DispatchQueue.main.async { [weak self] in
            self?.notifyIntrinsicSizeChanged()
        }
    }

    private func currentIntrinsicSize() -> CGSize {
        layoutSubtreeIfNeeded()
        hostingView.layoutSubtreeIfNeeded()

        let intrinsic = hostingView.intrinsicContentSize
        let intrinsicWidth = intrinsic.width
        let intrinsicHeight = intrinsic.height

        let hasValidIntrinsic =
            intrinsicWidth > 0 &&
            intrinsicHeight > 0 &&
            intrinsicWidth != NSView.noIntrinsicMetric &&
            intrinsicHeight != NSView.noIntrinsicMetric

        if hasValidIntrinsic {
            return intrinsic
        }

        let fitting = hostingView.fittingSize
        return CGSize(width: max(0, fitting.width), height: max(0, fitting.height))
    }

    private func notifyIntrinsicSizeChanged(force: Bool = false) {
        let size = currentIntrinsicSize()
        guard size.width > 0, size.height > 0 else {
            return
        }

        if !force, lastReportedIntrinsicSize == size {
            return
        }

        lastReportedIntrinsicSize = size
        channel.invokeMethod(
            "intrinsicSizeChanged",
            arguments: ["width": size.width, "height": size.height],
        )
    }
}

// MARK: - Toggle View

struct CupertinoToggleView: View {
    @ObservedObject var model: CNToggleModel

    var body: some View {
        buildToggle()
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                model.onSizeChanged(newValue)
            }
    }

    private func buildToggle() -> AnyView {
        let payload = model.payload
        let toggle = Toggle(isOn: Binding(
            get: { payload.value ?? false },
            set: { newValue in
                model.setValueFromUser(newValue)
            },
        )) {
            if payload.labelChildren.isEmpty {
                EmptyView()
            } else if payload.labelChildren.count == 1 {
                deserializeLabelChild(payload.labelChildren[0])
            } else {
                ForEach(Array(payload.labelChildren.enumerated()), id: \.offset) { _, child in
                    deserializeLabelChild(child)
                }
            }
        }

        var view = AnyView(toggle.disabled(!(payload.enabled ?? true)))
        view = AnyView(view.controlSize(SwiftUtils.controlSizeFromString(payload.controlSize)))

        if let tint = payload.tint {
            view = AnyView(view.tint(ColorUtils.swiftUIColorFromARGB(tint)))
        }

        if let foregroundColor = payload.foregroundColor {
            view = AnyView(view.foregroundStyle(ColorUtils.swiftUIColorFromARGB(foregroundColor)))
        }

        if let width = payload.width, let height = payload.height {
            view = AnyView(view.frame(width: CGFloat(width), height: CGFloat(height)))
        } else if let width = payload.width {
            view = AnyView(view.frame(width: CGFloat(width)))
        } else if let height = payload.height {
            view = AnyView(view.frame(height: CGFloat(height)))
        }

        switch payload.toggleStyle {
        case "automatic":
            return AnyView(view.toggleStyle(.automatic))
        case "checkbox":
            return AnyView(view.toggleStyle(.checkbox))
        case "button":
            return AnyView(view.toggleStyle(.button))
        case "switch":
            return AnyView(view.toggleStyle(.switch))
        default:
            return AnyView(view.toggleStyle(.automatic))
        }
    }

    @ViewBuilder
    private func deserializeLabelChild(_ child: CNToggleChildPayload) -> some View {
        switch child.type {
        case "image":
            CNImage.deserialize(child.payload) ?? AnyView(EmptyView())
        case "label":
            CNLabel.deserialize(child.payload) ?? AnyView(EmptyView())
        case "text":
            CNText.deserialize(child.payload) ?? AnyView(EmptyView())
        case "progressView":
            CNProgressViewDeserializer.deserialize(child.payload) ?? AnyView(EmptyView())
        default:
            AnyView(EmptyView())
        }
    }
}
