import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoToggleNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingController: NSHostingController<CupertinoToggleView>

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeToggle_\(viewId)", binaryMessenger: messenger
        )

        var initialValue = false
        var enabled = true
        var label: String? = nil
        var systemSymbolName: String? = nil
        var toggleStyle = "switch"
        var controlSize = "regular"
        var tint: NSColor? = nil

        if let dict = args as? [String: Any] {
            if let v = dict["value"] as? NSNumber { initialValue = v.boolValue }
            if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
            if let v = dict["label"] as? String { label = v }
            if let v = dict["systemSymbolName"] as? String { systemSymbolName = v }
            if let v = dict["toggleStyle"] as? String { toggleStyle = v }
            if let v = dict["controlSize"] as? String { controlSize = v }
            if let v = dict["tint"] as? Int {
                tint = ColorUtils.colorFromARGB(v)
            }
        }

        var channelRef: FlutterMethodChannel? = nil
        let model = ToggleModel(
            value: initialValue,
            enabled: enabled,
            label: label,
            systemSymbolName: systemSymbolName,
            toggleStyle: toggleStyle,
            controlSize: controlSize,
            tint: tint,
            onChanged: { newValue in
                channelRef?.invokeMethod("onChanged", arguments: ["value": newValue])
            },
            onSizeChanged: { newSize in
                channelRef?.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": newSize.width, "height": newSize.height]
                )
            }
        )

        hostingController = NSHostingController(rootView: CupertinoToggleView(model: model))
        super.init(frame: .zero)

        channelRef = channel

        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor

        addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "getIntrinsicSize":
                let size = self.hostingController.view.intrinsicContentSize
                result(["width": size.width, "height": size.height])
            case "setValue":
                if let args = call.arguments as? [String: Any],
                   let value = (args["value"] as? NSNumber)?.boolValue
                {
                    model.setValueFromDart(value)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setIsEnabled":
                if let args = call.arguments as? [String: Any],
                   let enabled = (args["value"] as? NSNumber)?.boolValue
                {
                    model.enabled = enabled
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
                }
            case "setControlSize":
                if let args = call.arguments as? [String: Any] {
                    model.controlSize = (args["controlSize"] as? String) ?? "regular"
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing controlSize", details: nil))
                }
            case "setTint":
                if let args = call.arguments as? [String: Any],
                   let tintValue = args["tint"] as? Int
                {
                    let ns = ColorUtils.colorFromARGB(tintValue)
                    model.tint = ns
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing tint", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder _: NSCoder) {
        return nil
    }
}

// MARK: - Toggle Model

class ToggleModel: ObservableObject {
    @Published var value: Bool
    @Published var enabled: Bool
    @Published var controlSize: String
    @Published var tint: NSColor?
    let label: String?
    let systemSymbolName: String?
    let toggleStyle: String
    var onChanged: (Bool) -> Void
    let onSizeChanged: (CGSize) -> Void

    init(
        value: Bool,
        enabled: Bool,
        label: String?,
        systemSymbolName: String?,
        toggleStyle: String,
        controlSize: String,
        tint: NSColor?,
        onChanged: @escaping (Bool) -> Void,
        onSizeChanged: @escaping (CGSize) -> Void
    ) {
        self.value = value
        self.enabled = enabled
        self.label = label
        self.systemSymbolName = systemSymbolName
        self.toggleStyle = toggleStyle
        self.controlSize = controlSize
        self.tint = tint
        self.onChanged = onChanged
        self.onSizeChanged = onSizeChanged
    }

    func toggle() {
        value.toggle()
        onChanged(value)
    }

    func setValueFromDart(_ newValue: Bool) {
        value = newValue
    }
}

// MARK: - Toggle View

struct CupertinoToggleView: View {
    @ObservedObject var model: ToggleModel
    @State private var measuredSize: CGSize = .zero

    var body: some View {
        buildToggle()
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                model.onSizeChanged(newValue)
            }
    }

    private func buildToggle() -> some View {
        let toggle = Toggle(isOn: Binding(
            get: { model.value },
            set: { newValue in
                model.value = newValue
                model.onChanged(newValue)
            }
        )) {
            if let symbol = model.systemSymbolName, let label = model.label {
                Label(label, systemImage: symbol)
            } else if let symbol = model.systemSymbolName {
                Image(systemName: symbol)
            } else if let label = model.label {
                Text(label)
            }
        }
        .disabled(!model.enabled)
        .controlSize(SwiftUtils.controlSizeFromString(model.controlSize))
        .tint(model.tint != nil ? Color(model.tint!) : nil)

        // Apply style based on configuration
        switch model.toggleStyle {
        case "automatic":
            return AnyView(toggle.toggleStyle(.automatic))
        case "checkbox":
            return AnyView(toggle.toggleStyle(.checkbox))
        case "button":
            return AnyView(toggle.toggleStyle(.button))
        case "switch":
            return AnyView(toggle.toggleStyle(.switch))
        default:
            return AnyView(toggle.toggleStyle(.automatic))
        }
    }
}
