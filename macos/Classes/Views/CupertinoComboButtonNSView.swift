import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoComboButtonNSView: NSView {
    private let channel: FlutterMethodChannel
    private let comboButton = NSComboButton(title: "", menu: nil, target: nil, action: nil)

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativeComboButton_\(viewId)", binaryMessenger: messenger)
        super.init(frame: .zero)

        var title = ""
        var enabled: Bool = true
        var isDark: Bool = false
        var menu: NSMenu? = nil
        var style: NSComboButton.Style = .split
        var image: NSImage? = nil

        if let dict = args as? [String: Any] {
            if let v = dict["title"] as? String { title = v }
            if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
            if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
            if let v = dict["style"] as? String {
                switch v {
                case "unified":
                    style = .unified
                default:
                    self.comboButton.style = .split
                }
            }
            if let v = dict["menu"] as? String {
                menu = self.deserializeMenu(v)
            }
            if let v = dict["image"] as? [String: Any] {
                image = CupertinoImageDeserializer.deserialize(dict: v)
            }
            if let v = dict["image"] as? String {
                image = CupertinoImageDeserializer.deserialize(jsonString: v)
            }
        }

        self.comboButton.style = style
        self.comboButton.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        self.comboButton.isEnabled = enabled
        self.comboButton.title = title
        if let image = image {
            self.comboButton.image = image
        }
        self.comboButton.menu = menu ?? NSMenu()

        self.comboButton.target = self
        self.comboButton.action = #selector(comboButtonToggled)

        addSubview(self.comboButton)

        self.comboButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.comboButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.comboButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.comboButton.topAnchor.constraint(equalTo: topAnchor),
            self.comboButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        self.channel.setMethodCallHandler { call, result in
            NSLog(
                "Received method call: \(call.method)"
            )
            switch call.method {
            case "getIntrinsicSize":
                let size = self.comboButton.intrinsicContentSize
                result(["width": size.width, "height": size.height])

            case "setIsDark":
                if let args = call.arguments as? [String: Any],
                    let isDark = (args["value"] as? NSNumber)?.boolValue
                {
                    self.comboButton.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
                }

            case "setIsEnabled":
                if let args = call.arguments as? [String: Any],
                    let enabled = (args["value"] as? NSNumber)?.boolValue
                {
                    self.comboButton.isEnabled = enabled
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
                }

            case "setControlSize":
                if let args = call.arguments as? [String: Any],
                    let controlSizeStr = args["value"] as? String
                {
                    self.comboButton.controlSize = ControlSizeUtils.controlSizeFromString(
                        controlSizeStr)
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing control size", details: nil))
                }

            case "setTitle":
                if let args = call.arguments as? [String: Any], let title = args["value"] as? String
                {
                    self.comboButton.title = title
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing title", details: nil))
                }
            case "setImage":
                if let args = call.arguments as? [String: Any],
                    let imageDict = args["value"] as? [String: Any]
                {
                    self.comboButton.image = CupertinoImageDeserializer.deserialize(dict: imageDict)
                    result(nil)
                } else if let args = call.arguments as? [String: Any],
                    let imageJson = args["value"] as? String
                {
                    self.comboButton.image = CupertinoImageDeserializer.deserialize(
                        jsonString: imageJson)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing image", details: nil))
                }
            case "setStyle":
                if let args = call.arguments as? [String: Any],
                    let styleStr = args["value"] as? String
                {
                    switch styleStr {
                    case "unified":
                        self.comboButton.style = .unified
                    default:
                        self.comboButton.style = .split
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
                }

            case "setMenu":
                if let args = call.arguments as? [String: Any],
                    let menuJson = args["value"] as? String
                {
                    self.comboButton.menu = self.deserializeMenu(menuJson)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing menu", details: nil))
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func comboButtonToggled(_ sender: NSComboButton) {
        if sender.isEnabled {
            if sender.style == .unified {
                // Force to open the menu, if not empty
                let p = NSPoint(x: 0, y: sender.frame.height)
                sender.menu.popUp(positioning: nil, at: p, in: sender)
            } else {
                channel.invokeMethod("comboButtonPressed", arguments: nil)
            }
        } else {
            NSLog("Combo button is disabled, ignoring press")
        }
    }

    @objc private func menuItemSelected(_ sender: NSMenuItem) {
        channel.invokeMethod(
            "menuItemSelected",
            arguments: [
                "title": sender.title, "tag": sender.tag,
                "index": sender.menu?.index(of: sender) ?? -1,
                "identifier": sender.identifier?.rawValue ?? "",
            ])
    }

    private func deserializeMenu(_ jsonString: String) -> NSMenu {
        let menu = NSMenu()

        if let data = jsonString.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [])
                    as? [String: Any],
                    let items = json["items"] as? [[String: Any]]
                {
                    var title: String? = nil
                    var identifier: String? = nil
                    var tag: Int? = nil
                    var enabled: Bool? = nil
                    var state: NSControl.StateValue? = nil
                    var image: NSImage? = nil

                    for item in items {
                        if let separator = item["separator"] as? Bool, separator {
                            menu.addItem(.separator())
                            continue
                        }

                        if let v = item["title"] as? String {
                            title = v
                        }
                        if let v = item["identifier"] as? String {
                            identifier = v
                        }
                        if let v = item["tag"] as? Int {
                            tag = v
                        }
                        if let v = item["enabled"] as? Bool {
                            enabled = v
                        }
                        if let v = item["state"] as? String {
                            switch v {
                            case "on":
                                state = NSControl.StateValue.on
                            case "off":
                                state = NSControl.StateValue.off
                            case "mixed":
                                state = NSControl.StateValue.mixed
                            default:
                                state = NSControl.StateValue.off
                            }
                        }
                        if let v = item["image"] as? [String: Any] {
                            image = CupertinoImageDeserializer.deserialize(dict: v)
                        }

                        if let title = title {
                            let menuItem = NSMenuItem(
                                title: title, action: #selector(menuItemSelected(_:)),
                                keyEquivalent: "")
                            menuItem.target = self

                            if let identifier = identifier {
                                menuItem.identifier = NSUserInterfaceItemIdentifier(
                                    rawValue: identifier)
                            }

                            if let tag = tag {
                                menuItem.tag = tag
                            }

                            if let enabled = enabled {
                                menuItem.isEnabled = enabled
                            }

                            if let state = state {
                                menuItem.state = state
                            }

                            if let image = image {
                                menuItem.image = image
                            }

                            menu.addItem(menuItem)
                        }
                    }

                }
            } catch {
                NSLog("Error deserializing menu JSON: \(error)")
            }
        }

        menu.autoenablesItems = false
        menu.selectionMode = .automatic
        return menu
    }

}
