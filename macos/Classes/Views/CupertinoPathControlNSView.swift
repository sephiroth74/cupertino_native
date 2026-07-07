import Cocoa
import FlutterMacOS
import SwiftUI
import UniformTypeIdentifiers

/// A native macOS view that displays a path control.
class CupertinoPathControlNSView: NSView {
    private let registrar: FlutterPluginRegistrar
    private let channel: FlutterMethodChannel
    private var coordinator: Coordinator?
    private let pathControl: NSPathControl
    private var currentPathStyle: String = "standard"
    private var currentPathSize: String = "regular"
    private var currentAllowedTypes: [String] = []
    private var isEnabled: Bool = true
    private var currentPath: String = "/"
    private var currentIsDirectory: Bool = false
    private var currentTint: NSColor?
    private var currentEditable: Bool = true

    init(viewId: Int64, args: Any?, registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        pathControl = NSPathControl()
        channel = FlutterMethodChannel(
            name: "CupertinoNativePathControl_\(viewId)", binaryMessenger: registrar.messenger,
        )
        super.init(frame: .zero)

        coordinator = Coordinator(parent: self)

        var path = "/"
        var isDirectory = false
        var controlSize = "regular"
        var controlStyle = "standard"
        var isDark = false
        var tint: NSColor? = nil
        var enabled = true
        var allowedTypes: [String] = []
        var editable = true

        if let dict = CNChannelSerialization.asDict(args) {
            if let v = dict["isDirectory"] as? NSNumber {
                isDirectory = v.boolValue
            }
            if let v = dict["isDark"] as? NSNumber {
                isDark = v.boolValue
            }
            if let e = dict["enabled"] as? NSNumber {
                enabled = e.boolValue
            }
            if let cs = dict["controlSize"] as? String {
                controlSize = cs
            }
            if let cs = dict["style"] as? String {
                controlStyle = cs
            }
            if let p = dict["path"] as? String {
                path = p
            }
            if let style = dict["tint"] as? [String: Any], let n = style["tint"] as? NSNumber {
                tint = ColorUtils.colorFromARGB(n.intValue)
            }
            if let at = dict["allowedTypes"] as? [String] {
                allowedTypes = at
            }
            if let e = dict["editable"] as? NSNumber {
                editable = e.boolValue
            }
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
        pathControl.isEditable = editable
        pathControl.allowedTypes = allowedTypes

        currentPath = path
        currentTint = tint
        currentEditable = editable
        currentPathSize = controlSize
        currentPathStyle = controlStyle
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
            guard let self else {
                result(nil)
                return
            }
            switch call.method {
            case "getIntrinsicSize":
                let s = pathControl.intrinsicContentSize
                result(["width": Double(s.width), "height": Double(s.height)])
            case "setStyle":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    if let n = args["tint"] as? NSNumber {
                        let color = ColorUtils.colorFromARGB(n.intValue)
                        // self.pathControl.tint = color
                        currentTint = color
                    }
                    if let bs = args["style"] as? String {
                        currentPathStyle = bs
                        switch bs {
                        case "standard":
                            pathControl.pathStyle = .standard
                        case "popup":
                            pathControl.pathStyle = .popUp
                        default:
                            pathControl.pathStyle = .standard
                        }
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
                }
            case "setControlSize":
                if let args = CNChannelSerialization.asDict(call.arguments),
                   let cs = args["controlSize"] as? String
                {
                    currentPathSize = cs
                    switch cs {
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
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing control size", details: nil,
                        ),
                    )
                }
            case "setPath":
                if let args = CNChannelSerialization.asDict(call.arguments), let path = args["path"] as? String,
                   let isDirectory = args["isDirectory"] as? Bool
                {
                    currentPath = path
                    currentIsDirectory = isDirectory
                    pathControl.url = URL(fileURLWithPath: path, isDirectory: isDirectory)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing path", details: nil))
                }
            case "setEnabled":
                if let args = CNChannelSerialization.asDict(call.arguments), let e = args["enabled"] as? NSNumber {
                    isEnabled = e.boolValue
                    pathControl.isEnabled = isEnabled
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
                }
            case "setBrightness":
                if let args = CNChannelSerialization.asDict(call.arguments),
                   let isDark = (args["isDark"] as? NSNumber)?.boolValue
                {
                    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
                }
            case "setAllowedTypes":
                if let args = CNChannelSerialization.asDict(call.arguments),
                   let at = args["allowedTypes"] as? [String]
                {
                    currentAllowedTypes = at
                    pathControl.allowedTypes = at
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing allowedTypes", details: nil,
                        ),
                    )
                }
            case "setEditable":
                if let args = CNChannelSerialization.asDict(call.arguments), let e = args["editable"] as? NSNumber {
                    currentEditable = e.boolValue
                    pathControl.isEditable = currentEditable
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing editable", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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
                guard let firstMenuItem = menu.item(at: 0) else { return }
                firstMenuItem.action = #selector(otherItemClick(_:))
                firstMenuItem.isEnabled = true
                firstMenuItem.target = self
            }
        }

        @objc func otherItemClick(_: NSMenuItem) {
            guard let parent else { return }
            guard parent.currentEditable else { return }
            guard let appWindow = parent.registrar.getFlutterWindow() else { return }

            let allowedTypesCount = parent.pathControl.allowedTypes?.count ?? 0
            let openPanel = NSOpenPanel()
            openPanel.showsHiddenFiles = false
            openPanel.canChooseDirectories = allowedTypesCount == 0
            openPanel.canChooseFiles = true
            openPanel.allowsMultipleSelection = false

            if allowedTypesCount > 0 {
                openPanel.allowedContentTypes = parent.pathControl.allowedTypes!.map {
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
