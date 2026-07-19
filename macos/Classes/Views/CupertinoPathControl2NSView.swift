import Cocoa
import FlutterMacOS
import UniformTypeIdentifiers

class CupertinoPathControl2NSView: NSView, NSPathControlDelegate {
    private let channel: FlutterMethodChannel
    private let pathControl = NSPathControl()
    private var isEnabled = true
    private var editable = true
    private var allowedTypes: [String] = []
    private var debugLog = false

    private func log(_ message: String) {
        guard debugLog else { return }
        NSLog("[CupertinoPathControl2NSView] \(message)")
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativePathControl2_\(viewId)",
            binaryMessenger: messenger,
        )
        super.init(frame: .zero)

        setupPathControl()
        applyArgs(args)
        configureChannel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPathControl() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        pathControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pathControl)
        NSLayoutConstraint.activate([
            pathControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            pathControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            pathControl.topAnchor.constraint(equalTo: topAnchor),
            pathControl.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        pathControl.delegate = self
        pathControl.action = #selector(onPressed(_:))
        pathControl.target = self
    }

    // MARK: - Payload handling

    private func applyArgs(_ rawArgs: Any?) {
        guard let args = rawArgs as? [String: Any] else { return }
        applyPayload(args)
    }

    private func applyPayload(_ args: [String: Any]) {
        if let value = args["debugLog"] as? Bool {
            debugLog = value
        }

        if let path = args["path"] as? String {
            let isDir = (args["isDirectory"] as? Bool) ?? false
            pathControl.url = URL(fileURLWithPath: path, isDirectory: isDir)
        } else if args.keys.contains("isDirectory"), let url = pathControl.url {
            let isDir = (args["isDirectory"] as? Bool) ?? false
            pathControl.url = URL(fileURLWithPath: url.path, isDirectory: isDir)
        }

        if let style = args["controlStyle"] as? String {
            switch style {
            case "popup":
                pathControl.pathStyle = .popUp
            default:
                pathControl.pathStyle = .standard
            }
        }

        if let size = args["controlSize"] as? String {
            switch size {
            case "mini": pathControl.controlSize = .mini
            case "small": pathControl.controlSize = .small
            case "regular": pathControl.controlSize = .regular
            case "large": pathControl.controlSize = .large
            case "extraLarge":
                if #available(macOS 26.0, *) {
                    pathControl.controlSize = .extraLarge
                } else {
                    pathControl.controlSize = .large
                }
            default: pathControl.controlSize = .regular
            }
        }

        if let enabled = args["enabled"] as? Bool {
            isEnabled = enabled
            pathControl.isEnabled = enabled
        }

        if let value = args["editable"] as? Bool {
            editable = value
            pathControl.isEditable = value
        }

        if let types = args["allowedTypes"] as? [String] {
            allowedTypes = types
            pathControl.allowedTypes = types
        } else if args.keys.contains("allowedTypes") {
            allowedTypes = []
            pathControl.allowedTypes = []
        }
    }

    // MARK: - Channel

    private func configureChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }

            switch call.method {
            case "setData":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    applyPayload(args)
                    log("setData keys=\(Array(args.keys))")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                }
            case "applyPatch":
                if let patch = CNChannelSerialization.asDict(call.arguments) {
                    applyPayload(patch)
                    log("applyPatch keys=\(Array(patch.keys))")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing patch args", details: nil))
                }
            case "getIntrinsicSize":
                let size = pathControl.intrinsicContentSize
                log("getIntrinsicSize -> \(size)")
                result(["width": Double(size.width), "height": Double(size.height)])
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - Actions

    @objc private func onPressed(_ sender: NSPathControl) {
        guard isEnabled else { return }
        let path = sender.clickedPathItem?.url?.path
        log("pressed: \(path ?? "nil")")
        channel.invokeMethod("pressed", arguments: path)
    }

    // MARK: - NSPathControlDelegate

    func pathControl(_: NSPathControl, willPopUp menu: NSMenu) {
        guard editable else { return }
        guard let firstMenuItem = menu.item(at: 0) else { return }
        firstMenuItem.action = #selector(openPanelAction(_:))
        firstMenuItem.isEnabled = true
        firstMenuItem.target = self
    }

    @objc private func openPanelAction(_: NSMenuItem) {
        guard editable else { return }
        guard let appWindow = window else { return }

        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = allowedTypes.isEmpty
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false

        if !allowedTypes.isEmpty {
            openPanel.allowedContentTypes = allowedTypes.compactMap {
                UTType(filenameExtension: $0)
            }
        }

        openPanel.beginSheetModal(for: appWindow) { [weak self] response in
            guard let self, response == .OK, let url = openPanel.url else { return }
            pathControl.url = url
            channel.invokeMethod("pressed", arguments: url.path)
        }
    }
}
