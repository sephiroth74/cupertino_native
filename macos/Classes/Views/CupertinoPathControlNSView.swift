import Cocoa
import FlutterMacOS
import SwiftUI
import UniformTypeIdentifiers

/// A native macOS view that displays a path control.
class CupertinoPathControlNSView: NSView {
    private let registrar: FlutterPluginRegistrar
    private let channel: FlutterMethodChannel
    private let pathControl: NSPathControl
    private var currentPathStyle: String = "standard"
    private var currentPathSize: String = "regular"
    private var currentAllowedTypes: [String] = []
    private var isEnabled: Bool = true
    private var currentPath: String = "/"
    private var currentIsDirectory: Bool = false
    private var currentTint: NSColor? = nil
    private var coordinator: Coordinator? = nil

    init(viewId: Int64, args: Any?, registrar: FlutterPluginRegistrar) {
        NSLog("init with registrar: \(registrar)")

        self.registrar = registrar
        self.pathControl = NSPathControl()
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativePathControl_\(viewId)", binaryMessenger: registrar.messenger)
        super.init(frame: .zero)

        self.coordinator = Coordinator(parent: self)

        var path: String = "/"
        var isDirectory = false
        var controlSize: String = "regular"
        var controlStyle: String = "standard"
        var isDark: Bool = false
        var tint: NSColor? = nil
        var enabled: Bool = true
        var allowedTypes: [String] = []

        if let dict = args as? [String: Any] {
            if let v = dict["isDirectory"] as? NSNumber { isDirectory = v.boolValue }
            if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
            if let e = dict["enabled"] as? NSNumber { enabled = e.boolValue }
            if let cs = dict["controlSize"] as? String { controlSize = cs }
            if let cs = dict["style"] as? String { controlStyle = cs }
            if let p = dict["path"] as? String { path = p }
            if let style = dict["tint"] as? [String: Any], let n = style["tint"] as? NSNumber {
                tint = ColorUtils.colorFromARGB(n.intValue)
            }
            if let at = dict["allowedTypes"] as? [String] { allowedTypes = at }
        }

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

        switch controlStyle {
        case "standard":
            pathControl.pathStyle = .standard
        case "popup":
            pathControl.pathStyle = .popUp
        default:
            pathControl.pathStyle = .standard
        }

        switch controlSize {
        case "mini": pathControl.controlSize = .mini
        case "small": pathControl.controlSize = .small
        case "regular": pathControl.controlSize = .regular
        case "large": pathControl.controlSize = .large
        case "extraLarge":
            pathControl.controlSize =
                if #available(macOS 26.0, *) {
                    .extraLarge
                } else {
                    .large
                }
        default: pathControl.controlSize = .regular
        }

        pathControl.isEnabled = enabled
        pathControl.url = URL(fileURLWithPath: path, isDirectory: isDirectory)
        pathControl.isEditable = true
        pathControl.allowedTypes = allowedTypes

        NSLog("allowedTypes: \(allowedTypes)")

        currentTint = tint
        currentPathSize = controlSize
        currentPathStyle = controlStyle
        currentPath = path
        currentIsDirectory = isDirectory
        currentAllowedTypes = allowedTypes
        isEnabled = enabled

        addSubview(pathControl)
        pathControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pathControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            pathControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            pathControl.topAnchor.constraint(equalTo: topAnchor),
            pathControl.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        pathControl.delegate = coordinator
        pathControl.action = #selector(onPressed(_:))

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }
            switch call.method {
            case "getIntrinsicSize":
                let s = self.pathControl.intrinsicContentSize
                result(["width": Double(s.width), "height": Double(s.height)])
            case "setStyle":
                if let args = call.arguments as? [String: Any] {
                    if let n = args["tint"] as? NSNumber {
                        let color = ColorUtils.colorFromARGB(n.intValue)
                        // self.pathControl.tint = color
                        self.currentTint = color
                    }
                    if let bs = args["style"] as? String {
                        self.currentPathStyle = bs
                        switch bs {
                        case "standard":
                            self.pathControl.pathStyle = .standard
                        case "popup":
                            self.pathControl.pathStyle = .popUp
                        default:
                            self.pathControl.pathStyle = .standard
                        }
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
                }
            case "setControlSize":
                if let args = call.arguments as? [String: Any],
                    let cs = args["controlSize"] as? String
                {
                    self.currentPathSize = cs
                    switch cs {
                    case "mini": self.pathControl.controlSize = .mini
                    case "small": self.pathControl.controlSize = .small
                    case "regular": self.pathControl.controlSize = .regular
                    case "large": self.pathControl.controlSize = .large
                    case "extraLarge":
                        self.pathControl.controlSize =
                            if #available(macOS 26.0, *) {
                                .extraLarge
                            } else {
                                .large
                            }
                    default: self.pathControl.controlSize = .regular
                    }
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing control size", details: nil))
                }
            case "setPath":
                if let args = call.arguments as? [String: Any], let path = args["path"] as? String,
                    let isDirectory = args["isDirectory"] as? Bool
                {
                    self.currentPath = path
                    self.currentIsDirectory = isDirectory
                    self.pathControl.url = URL(fileURLWithPath: path, isDirectory: isDirectory)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing path", details: nil))
                }
            case "setEnabled":
                if let args = call.arguments as? [String: Any], let e = args["enabled"] as? NSNumber
                {
                    self.isEnabled = e.boolValue
                    self.pathControl.isEnabled = self.isEnabled
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
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
            case "setAllowedTypes":
                if let args = call.arguments as? [String: Any],
                    let at = args["allowedTypes"] as? [String]
                {
                    self.currentAllowedTypes = at
                    self.pathControl.allowedTypes = at
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing allowedTypes", details: nil))
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onPressed(_ sender: NSPathControl) {
        guard isEnabled else { return }
        let path = sender.clickedPathItem?.url
        channel.invokeMethod("pressed", arguments: path?.path)
    }

    class Coordinator: NSObject, NSPathControlDelegate {
        weak var parent: CupertinoPathControlNSView?

        init(parent: CupertinoPathControlNSView) {
            self.parent = parent
        }

        func pathControl(_ pathControl: NSPathControl, willPopUp menu: NSMenu) {
            if pathControl.isEditable {
                menu.item(at: 0)?.action = #selector(otherItemClick(_:))
                menu.item(at: 0)?.isEnabled = true
                menu.item(at: 0)?.target = self
            }
        }

        @objc func otherItemClick(_ sender: NSMenuItem) {
            guard let appWindow = CupertinoNativePlugin.getFlutterWindow() else { return }

            let allowedTypesCount = parent?.pathControl.allowedTypes?.count ?? 0
            let openPanel = NSOpenPanel()
            openPanel.showsHiddenFiles = false
            openPanel.canChooseDirectories = allowedTypesCount == 0
            openPanel.canChooseFiles = true
            openPanel.allowsMultipleSelection = false

            if allowedTypesCount > 0 {
                openPanel.allowedContentTypes = parent!.pathControl.allowedTypes!.map {
                    UTType(filenameExtension: $0)!
                }
            }

            openPanel.beginSheetModal(for: appWindow) {
                response in
                if response == .OK {
                    if let url = openPanel.url {
                        self.parent?.channel.invokeMethod("pressed", arguments: url.path)
                    }
                }
            }
        }
    }
}
