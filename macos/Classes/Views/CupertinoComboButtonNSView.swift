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
        }

        self.comboButton.style = style
        self.comboButton.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        self.comboButton.isEnabled = enabled
        self.comboButton.title = title
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
                if let args = call.arguments as? [String: Any], let isDark = (args["value"] as? NSNumber)?.boolValue
                {
                    self.comboButton.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
                }

            case "setIsEnabled":
                if let args = call.arguments as? [String: Any], let enabled = (args["value"] as? NSNumber)?.boolValue
                {
                    self.comboButton.isEnabled = enabled
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
                }

            case "setControlSize":
                if let args = call.arguments as? [String: Any], let controlSizeStr = args["value"] as? String
                {
                    self.comboButton.controlSize = ControlSizeUtils.controlSizeFromString(controlSizeStr)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing control size", details: nil))
                }

            case "setTitle":
                if let args = call.arguments as? [String: Any], let title = args["value"] as? String {
                    self.comboButton.title = title
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing title", details: nil))
                }
            case "setStyle":
                if let args = call.arguments as? [String: Any], let styleStr = args["value"] as? String {
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
                if let args = call.arguments as? [String: Any], let menuJson = args["value"] as? String {
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
        NSLog("Menu item selected: \(sender.title) with identifier: \(sender.identifier)")
        channel.invokeMethod(
            "menuItemSelected",
            arguments: [
                "title": sender.title, "tag": sender.tag,
                "index": sender.menu?.index(of: sender) ?? -1,
                "identifier": sender.identifier?.rawValue ?? "",
            ])
    }

    /// Data is like:
    /// {
    //   "items": [
    //     {
    //       "title": "Mini",
    //       "tag": null,
    //       "symbolConfiguration": null,
    //       "submenu": null
    //     },
    //     {
    //       "title": "Small",
    //       "tag": null,
    //       "symbolConfiguration": null,
    //       "submenu": null
    //     },
    //     {
    //       "title": "Regular",
    //       "tag": null,
    //       "symbolConfiguration": null,
    //       "submenu": null
    //     },
    //     {
    //       "title": "Large",
    //       "tag": null,
    //       "image": {
    //          "systemSymbolName": "star.fill",
    //          "symbolConfiguration": {
    //              "type": "hierarchical",
    //              "hierarchicalColor": "#0000FF"
    //          }
    //       },
    //       "submenu": null
    //     }
    //   ]
    // }
    private func deserializeMenu(_ jsonString: String) -> NSMenu {
        NSLog("Deserializing menu from JSON: \(jsonString)")
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
                            image = self.deserializeImage(v)
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

    private func deserializeImage(_ dict: [String: Any]) -> NSImage? {
        if let systemSymbolName = dict["systemSymbolName"] as? String {
            var image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil)
            if let symbolConfig = dict["symbolConfiguration"] as? [String: Any] {
                if let type = symbolConfig["type"] as? String {

                    switch type {
                        case "hierarchical":
                            if let v = symbolConfig["color"] as? NSNumber {
                                let color = ColorUtils.colorFromARGB(v.intValue)
                                return image?.withSymbolConfiguration(NSImage.SymbolConfiguration(hierarchicalColor: color))
                            }
                        case "monochrome":
                            if let v = symbolConfig["color"] as? NSNumber {
                                let color = ColorUtils.colorFromARGB(v.intValue)
                                return image?.tinted(with: color)
                            }
                            return image?.withSymbolConfiguration(NSImage.SymbolConfiguration.preferringMonochrome())
                        case "multicolor":
                            return image?.withSymbolConfiguration(NSImage.SymbolConfiguration.preferringMulticolor())
                        default:
                            break
                    }
                }
            }
            return image
        }
        return nil
    }
}
