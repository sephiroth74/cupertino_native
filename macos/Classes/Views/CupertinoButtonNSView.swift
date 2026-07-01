import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoButtonNSView: NSView {
    private let channel: FlutterMethodChannel
    private var hostingController: NSHostingController<CupertinoButtonView>!
    private var model: ButtonModel!

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeButton_\(viewId)", binaryMessenger: messenger
        )
        super.init(frame: .zero)

        var title: String? = nil
        var iconName: String? = nil
        var buttonStyle: any PrimitiveButtonStyle = DefaultButtonStyle()
        var controlSize: ControlSize = .regular
        var isDark = false
        var tint: Color? = nil
        var enabled = true
        var buttonRole = "none"
        var imageScale = "medium"
        var symbolRenderingMode: SymbolRenderingMode? = nil

        if let dict = args as? [String: Any] {
            if let t = dict["buttonTitle"] as? String { title = t }
            if let s = dict["buttonIconName"] as? String { iconName = s }
            if let bs = dict["buttonStyle"] as? String { buttonStyle = bs.toButtonStyle() }
            if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
            if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber {
                tint = n.intValue.toARGB()
            }
            if let e = dict["enabled"] as? NSNumber { enabled = e.boolValue }
            if let role = dict["buttonRole"] as? String { buttonRole = role }
            if let cs = dict["controlSize"] as? String { controlSize = cs.toControlSize() ?? .regular }
            if let iscale = dict["imageScale"] as? String { imageScale = iscale }
            if let srm = dict["symbolRenderingMode"] as? String {
                symbolRenderingMode = srm.toSymbolRenderingMode()
            }
        }

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

        var channelRef: FlutterMethodChannel? = nil
        model = ButtonModel(
            title: title,
            iconName: iconName,
            buttonRole: buttonRole,
            buttonStyle: buttonStyle,
            controlSize: controlSize,
            tint: tint,
            isEnabled: enabled,
            imageScale: imageScale,
            symbolRenderingMode: symbolRenderingMode,
            onPressed: {
                channelRef?.invokeMethod("pressed", arguments: nil)
            },
            onSizeChanged: { _ in }
        )

        hostingController = NSHostingController(rootView: CupertinoButtonView(model: model))
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

        channelRef = channel

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }

            switch call.method {
            case "getIntrinsicSize":
                let s = self.hostingController.view.fittingSize
                result(["width": Double(s.width), "height": Double(s.height)])
            case "setStyle":
                if let args = call.arguments as? [String: Any] {
                    if let n = args["tint"] as? NSNumber {
                        self.model.tint = n.intValue.toARGB()
                    }
                    if let bs = args["buttonStyle"] as? String {
                        self.model.buttonStyle = bs.toButtonStyle()
                    }
                    if let role = args["buttonRole"] as? String {
                        self.model.buttonRole = role
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
                }
            case "setControlSize":
                if let args = call.arguments as? [String: Any], let cs = args["controlSize"] as? String {
                    self.model.controlSize = cs.toControlSize() ?? .regular
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing control size", details: nil))
                }
            case "setImageScale":
                if let args = call.arguments as? [String: Any], let iscale = args["imageScale"] as? String {
                    self.model.imageScale = iscale
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing image scale", details: nil))
                }
            case "setButtonTitle":
                if let args = call.arguments as? [String: Any], let t = args["title"] as? String {
                    self.model.title = t
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing title", details: nil))
                }
            case "setEnabled":
                if let args = call.arguments as? [String: Any], let e = args["enabled"] as? NSNumber {
                    self.model.isEnabled = e.boolValue
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
                }
            case "setButtonIcon":
                if let args = call.arguments as? [String: Any] {
                    if let name = args["buttonIconName"] as? String {
                        self.model.iconName = name
                    }
                    if let srm = args["symbolRenderingMode"] as? String {
                        self.model.symbolRenderingMode = srm.toSymbolRenderingMode()
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing icon args", details: nil))
                }
            case "setBrightness":
                if let args = call.arguments as? [String: Any],
                   let isDark = (args["isDark"] as? NSNumber)?.boolValue
                {
                    self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
                }
            case "setPressed":
                if let args = call.arguments as? [String: Any], let p = args["pressed"] as? NSNumber {
                    self.model.isPressed = p.boolValue
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing pressed", details: nil))
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

private final class ButtonModel: ObservableObject {
    @Published var title: String?
    @Published var iconName: String?
    @Published var buttonRole: String
    @Published var buttonStyle: any PrimitiveButtonStyle
    @Published var controlSize: ControlSize
    @Published var tint: Color?
    @Published var isEnabled: Bool
    @Published var isPressed: Bool = false
    @Published var imageScale: String
    @Published var symbolRenderingMode: SymbolRenderingMode?
    let onPressed: () -> Void
    let onSizeChanged: (CGSize) -> Void

    init(
        title: String?,
        iconName: String?,
        buttonRole: String,
        buttonStyle: any PrimitiveButtonStyle,
        controlSize: ControlSize,
        tint: Color?,
        isEnabled: Bool,
        imageScale: String,
        symbolRenderingMode: SymbolRenderingMode?,
        onPressed: @escaping () -> Void,
        onSizeChanged: @escaping (CGSize) -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.buttonRole = buttonRole
        self.buttonStyle = buttonStyle
        self.controlSize = controlSize
        self.tint = tint
        self.isEnabled = isEnabled
        self.imageScale = imageScale
        self.symbolRenderingMode = symbolRenderingMode
        self.onPressed = onPressed
        self.onSizeChanged = onSizeChanged
    }
}

private struct CupertinoButtonView: View {
    @ObservedObject var model: ButtonModel

    private var imageScaleValue: Image.Scale {
        switch model.imageScale {
        case "small":
            return .small
        case "large":
            return .large
        default:
            return .medium
        }
    }

    private var roleValue: ButtonRole? {
        switch model.buttonRole {
        case "cancel":
            return .cancel
        case "destructive":
            return .destructive
        case "confirm":
            return .confirm
        case "close":
            return .close
        default:
            return nil
        }
    }

    var body: some View {
        buildButton()
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                model.onSizeChanged(newSize)
            }
    }

    private func onButtonPressed() {
        guard model.isEnabled else { return }
        model.onPressed()
    }

    private func buildButton() -> some View {
        let title = model.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasTitle = (title?.isEmpty == false)
        let hasIcon = (model.iconName?.isEmpty == false)

        let baseButton: AnyView
        if hasTitle, hasIcon {
            baseButton = AnyView(Button {
                onButtonPressed()
            } label: {
                HStack {
                    Image(systemName: model.iconName!)
                    Text(title!)
                }
            })
        } else if hasTitle {
            baseButton = AnyView(Button(title!, role: roleValue, action: onButtonPressed))
        } else if hasIcon {
            baseButton = AnyView(Button {
                onButtonPressed()
            } label: {
                Image(systemName: model.iconName!)
            })
        } else {
            baseButton = AnyView(Button("", role: roleValue, action: onButtonPressed))
        }

        let button = baseButton
            .disabled(!model.isEnabled)
            .controlSize(model.controlSize)
            .opacity(model.isPressed ? 0.7 : 1.0)
            .imageScale(imageScaleValue)
            .symbolRenderingMode(model.symbolRenderingMode)
            .buttonStyle(model.buttonStyle)

        if model.tint != nil {
            let tintedButton = button.tint(model.tint!)
            return AnyView(tintedButton)
        }

        return AnyView(button)
    }
}
